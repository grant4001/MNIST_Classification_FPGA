library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo is
generic
(
	constant FIFO_DATA_WIDTH : integer;
	constant FIFO_BUFFER_SIZE : integer
);
port
(
	signal rd_clk : in std_logic;
	signal wr_clk : in std_logic;
	signal reset : in std_logic;
	signal rd_en : in std_logic;
	signal wr_en : in std_logic;
	signal din : in std_logic_vector ((FIFO_DATA_WIDTH - 1) downto 0);
	signal dout : out std_logic_vector ((FIFO_DATA_WIDTH - 1) downto 0);
	signal full : out std_logic;
	signal empty : out std_logic
);
end entity fifo;


architecture behavior of fifo is 

	function if_cond( test : boolean; true_cond : std_logic_vector; false_cond : std_logic_vector )
	return std_logic_vector is 
	begin
		if ( test ) then
			return true_cond;
		else
			return false_cond;
		end if;
	end if_cond;


	function if_cond( test : boolean; true_cond : std_logic; false_cond : std_logic )
	return std_logic is 
	begin
		if ( test ) then
			return true_cond;
		else
			return false_cond;
		end if;
	end if_cond;


	function to01( input : std_logic_vector )
	return std_logic_vector is 
		variable i : integer;
		variable result : std_logic_vector ((input'length - 1) downto 0);
		variable tmp : std_logic_vector ((input'length - 1) downto 0);
	begin
		tmp := input(input'range);
		for i in 0 to (input'length - 1) loop

			case ( tmp(i) ) is 
				when '0' =>
					result(i) := '0';

				when '1' =>
					result(i) := '1';

				when OTHERS =>
					result(i) := '0';

			end case;
		end loop;
		return result;
	end to01;


	function if_cond( test : boolean; true_cond : integer; false_cond : integer )
	return integer is 
	begin
		if ( test ) then
			return true_cond;
		else
			return false_cond;
		end if;
	end if_cond;


	function log2( input : integer )
	return integer is 
		variable log : integer;
		variable tmp : integer;
	begin
		tmp := input;
		log := 0;
		while tmp > 1 loop
			tmp := tmp / 2;
			log := log + 1;
		end loop;
		if ( (input /= 0) and (input /= (to_unsigned(1, 32) SLL log)) ) then
			log := log + 1;
		end if;
		return log;
	end log2;

	constant NUM_ELEMENTS : integer := FIFO_BUFFER_SIZE;
	constant ADDR_SIZE : integer := if_cond(log2(NUM_ELEMENTS) >= 1, log2(NUM_ELEMENTS), 1) + 1;
	type ARRAY_SLV_FIFO_DATA_WIDTH is array ( natural range <> ) of std_logic_vector ((FIFO_DATA_WIDTH - 1) downto 0);
	signal fifo_buf : ARRAY_SLV_FIFO_DATA_WIDTH (0 to (NUM_ELEMENTS - 1));
	signal write_addr : std_logic_vector ((ADDR_SIZE - 1) downto 0);
	signal read_addr : std_logic_vector ((ADDR_SIZE - 1) downto 0);
	signal write_addr_t : std_logic_vector ((ADDR_SIZE - 1) downto 0);
	signal read_addr_t : std_logic_vector ((ADDR_SIZE - 1) downto 0);
	signal full_t : std_logic;
	signal empty_t : std_logic;

begin

	p_write_buffer : process
	(
		wr_clk
	)
	begin
		if ( rising_edge(wr_clk) ) then
			if ( (wr_en = '1') and (full_t = '0') ) then
				fifo_buf(to_integer(unsigned(write_addr((ADDR_SIZE - 2) downto 0)))) <= din;
			end if;
		end if;
	end process p_write_buffer;


	p_read_buffer : process
	(
		rd_clk
	)
	begin
		if ( rising_edge(rd_clk) ) then
			dout <= to01(fifo_buf(to_integer(unsigned(read_addr_t((ADDR_SIZE - 2) downto 0)))));
		end if;
	end process p_read_buffer;


	p_write_addr : process
	(
		wr_clk, 
		reset
	)
	begin
		if ( reset = '0' ) then
			write_addr <= std_logic_vector(resize(to_unsigned(0, 2), ADDR_SIZE));
		elsif ( rising_edge(wr_clk) ) then
			write_addr <= write_addr_t;
		end if;
	end process p_write_addr;


	p_read_addr : process
	(
		rd_clk, 
		reset
	)
	begin
		if ( reset = '0' ) then
			read_addr <= std_logic_vector(resize(to_unsigned(0, 2), ADDR_SIZE));
		elsif ( rising_edge(rd_clk) ) then
			read_addr <= read_addr_t;
		end if;
	end process p_read_addr;


	p_empty : process
	(
		rd_clk, 
		reset
	)
	begin
		if ( reset = '0' ) then
			empty <= '1';
		elsif ( rising_edge(rd_clk) ) then
			empty <= if_cond(unsigned(write_addr) = unsigned(read_addr_t), '1', '0');
		end if;
	end process p_empty;

	full <= full_t;
	full_t <= if_cond((unsigned(write_addr((ADDR_SIZE - 2) downto 0)) = unsigned(read_addr((ADDR_SIZE - 2) downto 0))) and (write_addr(ADDR_SIZE - 1) /= read_addr(ADDR_SIZE - 1)), '1', '0');
	empty_t <= if_cond(unsigned(write_addr) = unsigned(read_addr), '1', '0');
	read_addr_t <= if_cond((rd_en = '1') and (empty_t = '0'), std_logic_vector(unsigned(read_addr) + resize(to_unsigned(1, 2), ADDR_SIZE)), read_addr);
	write_addr_t <= if_cond((wr_en = '1') and (full_t = '0'), std_logic_vector(unsigned(write_addr) + resize(to_unsigned(1, 2), ADDR_SIZE)), write_addr);

end architecture behavior;
