# GA-NN-Car
A MATLAB simple interactive Reinforcement Learning environment for Evolutionary Neural Network-based car with a proximity sensor

## Table of Contents
- [int-end-to-end-ad](#int-end-to-end-ad)
  * [Table of Contents](#table-of-contents)
  * [Notes](#notes)
  * [To-Do](#to-do)

## Paper Link
- arXiv: https://arxiv.org/abs/1609.08414
- Science and Technology Publications, Lda: http://www.scitepress.org/PublicationsDetail.aspx?ID=%2F+JoYnlE148%3D
- Please cite: [Hesham M. Eraqi, Youssef Emad Eldin, and Mohamed N. Moustafa. Reactive Collision Avoidance using Evolutionary Neural Network. The 8th International Joint Conference on Computational Intelligence (IJCCI), Porto, Portugal, November 9-11, 2016.]

  
## Description

### Project Description :
This is a fully configurable MATLAB project that implements and provides simulation for vehicle self-learning of collision avoidance and navigation with a rangefinder sensor using an evolutionary artificial neural network. The neural network guides the vehicle around the environment and a genetic algorithm is used to pick and breed generations of more intelligent vehicles.
The vehicle uses a rangefinder sensor that calculates N intersections depths with the environment and then feeds these N values as inputs to the neural network. The inputs are then passed through a neural network and finally to an output layer of 2 neurons: a left and right steering force. These forces are used to turn the vehicle by deciding the vehicle steering angle.
Each vehicle represents a different chromosome in a generation (or a unique set weight for the neural net) which are evaluated and potentially carried through to the next generation by a fitness score. The fitness score has different definition in each of my three experiments for collision avoidance and navigation self-learning.

### Code Configurations
- The vehicles dimensions and its wheels (base and dimensions)
- Rangefinder range and number of beams
- The environment
- Neural network architecture
- Number of vehicles and their replacement strategy
- The generic algorithm parameters: mutation probability, crossover probability, crossover site probability distribution, population size, selection strategy, replacement strategy …

### Simple 2D vehicle steering physics
Given the vehicle speed and simulation time tick Δt the travelled distance L per a single time step is calculated. Given wheel base, vehicle position P, heading θ, and distance travelled per time step L, the new vehicle position Pnew and heading θnew are calculated as shown in figure 1. Video 1 shows a simulation result.

| ![figure1](/_read_me_images/figure_1.png = x200) | 
|:--:| 
| *Figure 1. Simple 2D vehicle steering physics* |

<iframe width="560" height="315"
src="https://www.youtube.com/embed/Wx4s0svjlvE" 
frameborder="0" 
allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" 
allowfullscreen></iframe>
*Video 1. Simple 2D vehicle steering physics in action*



<div class="separator" style="clear: both; text-align: center;"><iframe allowfullscreen="" class="YOUTUBE-iframe-video" data-thumbnail-src="https://i.ytimg.com/vi/Wx4s0svjlvE/0.jpg" frameborder="0" height="266" src="https://www.youtube.com/embed/Wx4s0svjlvE?feature=player_embedded" width="320"></iframe></div>