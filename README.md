# MNIST_Classification_FPGA



| Demo Pt. 1 | Demo Pt. 2 | Demo Pt. 3 |
| ---------- | ---------- | ---------- |
| <a href="https://imgflip.com/gif/3m1jlr"><img src="https://i.imgflip.com/3m1jlr.gif" title="made at imgflip.com"/></a> | <a href="https://imgflip.com/gif/3m1kcb"><img src="https://i.imgflip.com/3m1kcb.gif" title="made at imgflip.com"/></a> | <a href="https://imgflip.com/gif/3m1l4s"><img src="https://i.imgflip.com/3m1l4s.gif" title="made at imgflip.com"/></a> |

Over the past decade, we have witnessed a significant boom in the machine learning and deep learning realm. A major subcategory of problems within the deep learning space is image processing and classification, which is widely used in real-time embedded applications such as autonomous driving, face recognition, robotics, and medical diagnosis. The booming popularity and work done on deep learning provides ample motivation to find ways to optimize and accelerate these algorithms, especially on unique computing platforms. For this project, I implemented a Convolutional Neural Network that uses MNIST handwritten digit classification as the benchmark. 

MATLAB was used to train the CNN; existing versions of the feed-forward and back-propagation algorithms, provided by Ashutosh Kumar Upadhyay, were used (source: https://www.mathworks.com/matlabcentral/fileexchange/59223-convolution-neural-network-simple-code-simple-to-use). 

The CNN architecture is a 7-layer network which features a mix of convolutional, pooling, and fully connected layers. The input layer is a 30x30 grayscale MNIST image, and the output is a 10x1 classification vector.

<p align="center">
  <img src="https://github.com/grant4001/MNIST_Classification_FPGA/blob/master/images/flow.png">
</p>

A highly-optimized GPU-like MAC (Multiplier-Accumulator) array core is implemented in the fabric of the FPGA, which allows for efficient, parallelized computation of activation layers. Other hardware blocks are optimized to perform tasks such as memory control, line buffering, and tensor sending and receiving. In addition, a specialized sliding window implementation of a line buffer is used to send feature map data to the first two convolutional layers, to avoid expensive memory accesses.

The hardware was written in SystemVerilog, the synthesis was done in Quartus Prime (Lite) v18.1, and simulations were done on vsim (ModelSim) and Cadence Incisiv. The targetted device was the Intel Cyclone IV FPGA. The list of primary components used is as follows:

(1) Terasic DE2-115 University Program Development Board

(2) Terasic D8M GPIO (Image sensor)

(3) VGA Monitor

To synthesize, open Project_FPGA/DE2_115_D8M_RTL/DE2_115_D8M_RTL.qpf on Quartus Prime. Hit "Compile Design."

Connect all of these components together. Hook up a USB cable from your computer to the USB blaster port of the DE2-115. To run, go into Project_FPGA/DE2_115_D8M_RTL/demo_batch and (if you're running Linux) modify test.sh so that your Quartus directories are in the right place. Open the terminal, type "./test.sh", and press enter. If you're running Windows, type "test.bat", and press enter.



EXTRAS:

Simulation Screenshot:
<p align="center">
  <img src="https://github.com/grant4001/MNIST_Classification_FPGA/blob/master/images/SimulationScreenCap.png">
</p>

Quartus Compilation Screenshot:
<p align="center">
  <img src="https://github.com/grant4001/MNIST_Classification_FPGA/blob/master/images/quartus_syn.png">
</p>



