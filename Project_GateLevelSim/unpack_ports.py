import math

def main_func():
    name = 'fmap_rd_data_III'
    x = open("expanded_ports.txt", "w")

    
    #for i in range(0, 16):
    #    for j in range(0, 2):
    #        PORT = '\\' + name + '[' + str(i) + '][' + str(j) + ']'
    #        x.write('.' + PORT + '\t' + '(' + PORT + '\t' + ')' + ',')
    #        x.write('\n')

    for i in range(0, 64):
        PORT = '\\' + name + '[' + str(i) + ']'
        x.write('.' + PORT + '\t' + '(' + PORT + '\t' + ')' + ',')
        x.write('\n')


if __name__ == '__main__':
    main_func()