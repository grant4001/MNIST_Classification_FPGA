# MNIST_Classification_FPGA

<iframe src='https://gfycat.com/ifr/DeliriousSmoggyAngwantibo' frameborder='0' scrolling='no' allowfullscreen width='640' height='1182'></iframe><p> <a href="https://gfycat.com/delirioussmoggyangwantibo">via Gfycat</a></p>

In this research project, I intend to explore deep learning acceleration on an FPGA platform. One subcategory of problems in the deep learning space is image processing/classification, which is used in real-time embedded applications such as autonomous driving, face recognition, robotics, and medical diagnosis. The benchmark chosen for this project is handwritten digit classification, which uses the MNIST dataset for training and testing. The ML architecture used is the Convolutional Neural Network, which exploits the spatial dependence of visual features. 

MATLAB was used to train the CNN; existing versions of the feed-forward and back-propagation algorithms, provided by Ashutosh Kumar Upadhyay, were used (source: https://www.mathworks.com/matlabcentral/fileexchange/59223-convolution-neural-network-simple-code-simple-to-use). 

The CNN architecture is a 7-layer network which features a mix of convolutional, pooling, and fully connected layers. The input layer is a 30x30 grayscale MNIST image, and the output is a 10x1 classification vector.

![alt text](https://github.com/grant4001/MNIST_Classification_FPGA/blob/master/images/flow.png)

A highly-optimized GPU-like MAC (Multiplier-Accumulator) array core is implemented in the fabric of the FPGA, which allows for efficient, parallelized computation of activations. Other hardware blocks are optimized to perform pertinent tasks such as memory control, line buffering, and tensor sending and receiving. 

The hardware is described using SystemVerilog, the synthesis was done using Quartus Prime Lite 18.1, and the simulation was done using vsim (ModelSim). The target device is the Cyclone IV FPGA. The list of primary components used is as follows:

(1) Terasic DE2-115 University Program Development Board
(2) Terasic D8M GPIO (Image sensor)
(3) VGA Monitor

To run, connect all of these components together. Hook up a USB cable from your computer to the USB blaster port of the DE2-115. 

Go into Project_FPGA/DE2_115_D8M_RTL/demo_batch and (if you're running Linux) modify test.sh so that your Quartus directories are in the right place.
Open the terminal, type "./test.sh", and press enter. If you're running Windows, type "test.bat", and press enter.

