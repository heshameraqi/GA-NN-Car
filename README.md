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

<center>
| <img src="/_read_me_images/figure_1.png" height="150"> |
|:--:| 
| *Figure 1. Simple 2D vehicle steering physics* |
</center>

<center>
| <a href="http://www.youtube.com/watch?v=Wx4s0svjlvE"><img alt="W3Schools" src="http://img.youtube.com/vi/Wx4s0svjlvE/0.jpg" height="150"> </a> |
|:--:| 
| *Video 1. Simple 2D vehicle steering physics in action* |
</center>

### Self-learning Navigation Experiment
Fitness function is chosen to be the distance that the vehicle traveled along the track before it collides with track boundaries. I was surprised by how fast vehicles learn navigation without any human interaction! In less than 50 generations with each generation having a population of 200 chromosomes, and with a neural network of only 3 hidden layers, perfect navigation is learnt! Mutation probability is 0.1, crossover probability is 1, cross over site follows the normal distribution: ~N(95%,5%), selection is based on tournaments of size 10 candidates, and all children replace their parents replacement strategy is adopted.

There is an interesting observation here. For the track map shown in figure 2, the vehicle took 12 generations to learn how to successfully turn in the first critical location A marked by red circle in the figure. Once the vehicle learns that, it achieves a huge fitness increase by implicitly learning how drive through all the following tricky turns in the track. This fact is demonstrated in figure 3 plot. This interesting because it is similar to the way humans learn things. The same effect happens for the vehicle to learn how to turn by 180° in the critical learning location B.

<center>
| <img src="/_read_me_images/figure_2.png" height="150"> |
|:--:| 
| *Figure 2. A track critical learning locations* |
</center>

As in figure 3, after 12 generations, the vehicle tries to learn how to turn by 180° in the critical learning location B, so it modifies its behavior but in a way that makes it fail to pass through the critical location A. This is why the fitness decreases again after it has increased, and that repeats until the vehicle learns to avoid such bad behavior by itself. However, the vehicle still fails to turn by 180°, and this is why the fitness function saturates. Actually, the road is too narrow for the vehicle to learn how to achieve that tricky 180° turn in a small number of learning generations. In another experiment, I modified the track to have a wider width (30 meters width instead of 12 meters, new map is also shown in figure 4). In only 16 iterations the vehicle learned to do that tricky 180° turn and navigate through the map almost forever without colliding! (Specifically, the car travelled the whole track more than 100 times until I stopped it manually.)

<center>
| <img src="/_read_me_images/figure_3.png" height="150"> |
|:--:| 
| *Figure 3. Fitness function per generation for figure 3 track set-up* |
</center>

<center>
| <img src="/_read_me_images/figure_4.png" height="150"> |
|:--:| 
| *Figure 4. Fitness function per generation for figure 3 track set-up with a wider track* |
</center>

<center>
| <a href="http://www.youtube.com/watch?v=sne69zu5gAA"><img src="http://img.youtube.com/vi/sne69zu5gAA/0.jpg" height="150"></a> |
|:--:| 
| *Video 2. Navigation Self-learning* |
</center>

For the track map of figure 5, the time traveled by the vehicle before crash for each generation is shown for different rangefinder sensor number of beams. Moderate number of beams (5 beams performed best) is proven to be the better. Figure 6 shows the same information for different rangefinder sensor ranges. The higher the sensor range is proven to be the better.

<center>
| <img src="/_read_me_images/figure_5.png" height="150"> |
|:--:| 
| *Figure 5. Fitness per generation for different number of rangefinder sensor number of beams* |
</center>

<center>
| <img src="/_read_me_images/figure_6.png" height="150"> |
|:--:| 
| *Figure 6. Fitness per generation for different number of rangefinder sensor ranges* |
</center>

It’s important to mention that to prevent vehicles from rotating around themselves, a trick that is described later (section 6) in this report is used.

### Can vehicle learn route to a specific destination?
With a simple modification to the fitness function, such that the fitness function becomes the subtraction of the vehicle drive time before collision and the Euclidean distance between the vehicle position and the destination location just before collision, the vehicle easily learns its route to the destination. In my recorded video for this experiment, it took the vehicle only 7 generations to learn its route to a far destination!


