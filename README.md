# MNIST_Classification_FPGA

In this research project, I intend to explore deep learning acceleration on an FPGA platform. One subcategory of problems in the deep learning space is image processing/classification, which is used in real-time embedded applications such as autonomous driving, face recognition, robotics, and medical diagnosis. The benchmark chosen for this project is handwritten digit classification, which uses the MNIST dataset for training and testing. The ML architecture used is the Convolutional Neural Network, which exploits the spatial dependence of visual features. 

MATLAB was used to train the CNN; existing versions of the feed-forward and back-propagation algorithms, provided by Ashutosh Kumar Upadhyay, were used (source: https://www.mathworks.com/matlabcentral/fileexchange/59223-convolution-neural-network-simple-code-simple-to-use). 

The CNN architecture is a 7-layer network which features a mix of convolutional, pooling, and fully connected layers. The input layer is a 30x30 grayscale MNIST image, and the output is a 10x1 classification vector.

![alt text](https://raw.githubusercontent.com/grant4001/images/flow.png)

A highly-optimized GPU-like MAC (Multiplier-Accumulator) array core is implemented in the fabric of the FPGA, which allows for efficient, parallelized computation of activations. Other hardware blocks are optimized to perform pertinent tasks such as memory control, line buffering, and tensor sending and receiving. 

The hardware is described using SystemVerilog, the synthesis was done using Quartus Prime Lite 18.1, and the simulation was done using vsim (ModelSim). The target device is the Cyclone IV FPGA. The list of primary components used is as follows:

(1) Terasic DE2-115 University Program Development Board
(2) Terasic D8M GPIO (Image sensor)
(3) VGA Monitor




