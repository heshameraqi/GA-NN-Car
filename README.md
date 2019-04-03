# GA-NN-Car
A MATLAB simple interactive Reinforcement Learning environment for Evolutionary Neural Network-based car with a proximity sensor

<div dir="ltr" style="text-align: left;" trbidi="on">

<div style="text-align: center;">

<div style="text-align: justify;"><span style="color: blue; font-size: large; text-align: left;">1- Project Description</span></div>

</div>

<div style="text-align: justify;">This is a fully configurable MATLAB project that implements and provides simulation for vehicle self-learning of collision avoidance and navigation with a rangefinder sensor using an evolutionary artificial neural network. The neural network guides the vehicle around the environment and a genetic algorithm is used to pick and breed generations of more intelligent vehicles.</div>

<div style="text-align: justify;">The vehicle uses a rangefinder sensor that calculates N intersections depths with the environment and then feeds these N values as inputs to the neural network. The inputs are then passed through a neural network and finally to an output layer of 2 neurons: a left and right steering force. These forces are used to turn the vehicle by deciding the vehicle steering angle.</div>

<div style="text-align: justify;">Each vehicle represents a different chromosome in a generation (or a unique set weight for the neural net) which are evaluated and potentially carried through to the next generation by a fitness score. The fitness score has different definition in each of my three experiments for collision avoidance and navigation self-learning.</div>

<div style="text-align: justify;"><span style="color: blue; font-size: large;">2- Software Configurations</span></div>

* The vehicles dimensions and its wheels (base and dimensions) * Rangefinder range and number of beams * The environment * Neural network architecture * Number of vehicles and their replacement strategy * The generic algorithm parameters: mutation probability, crossover probability, crossover site probability distribution, population size, selection strategy, replacement strategy …

<div style="text-align: justify;"><span style="color: red;">(I consider providing the source code, so please just leave a comment if you need it.)</span></div>

<span style="color: blue; font-size: large;">3- Simple 2D vehicle steering physics</span>

<div style="text-align: justify;">Given the vehicle speed and simulation time tick Δt the travelled distance L per a single time step is calculated. Given wheel base, vehicle position P, heading θ, and distance travelled per time step L, the new vehicle position Pnew and heading θnew are calculated as shown in figure 1\. Video 1 shows a simulation result.</div>

<div style="text-align: center;">[![](https://1.bp.blogspot.com/-liM0qvJwUvo/VnItIss9OuI/AAAAAAAAJ4o/d0w14PVqgDc/s320/Temp.png)](http://1.bp.blogspot.com/-liM0qvJwUvo/VnItIss9OuI/AAAAAAAAJ4o/d0w14PVqgDc/s1600/Temp.png)</div>

<div style="text-align: center;">**Figure 1\. Simple 2D vehicle steering physics**</div>

<div>

<div style="text-align: center;">

<div class="separator" style="clear: both; text-align: center;"><iframe allowfullscreen="" class="YOUTUBE-iframe-video" data-thumbnail-src="https://i.ytimg.com/vi/Wx4s0svjlvE/0.jpg" frameborder="0" height="266" src="https://www.youtube.com/embed/Wx4s0svjlvE?feature=player_embedded" width="320"></iframe></div>

<div class="separator" style="clear: both; text-align: center;">**Video 1\. Simple 2D vehicle steering physics in action**</div>

</div>

<span style="color: blue; font-size: large;">4- Self-learning Navigation Experiment</span>

<div style="text-align: justify;">Fitness function is chosen to be the distance that the vehicle traveled along the track before it collides with track boundaries. I was surprised by how fast vehicles learn navigation without any human interaction! In less than 50 generations with each generation having a population of 200 chromosomes, and with a neural network of only 3 hidden layers, perfect navigation is learnt! Mutation probability is 0.1, crossover probability is 1, cross over site follows the normal distribution: ~N(95%,5%), selection is based on tournaments of size 10 candidates, and all children replace their parents replacement strategy is adopted.</div>

<div style="text-align: justify;">There is an interesting observation here. For the track map shown in figure 2, the vehicle took 12 generations to learn how to successfully turn in the first critical location A marked by red circle in the figure. Once the vehicle learns that, it achieves a huge fitness increase by implicitly learning how drive through all the following tricky turns in the track. This fact is demonstrated in figure 3 plot. This interesting because it is similar to the way humans learn things. The same effect happens for the vehicle to learn how to turn by 180° in the critical learning location B.</div>

<div style="text-align: center;">[![](https://2.bp.blogspot.com/-YsX8A0NkoyA/VnIt4rNH9LI/AAAAAAAAJ4w/rFs3C7ARPBA/s320/Temp2.png)](http://2.bp.blogspot.com/-YsX8A0NkoyA/VnIt4rNH9LI/AAAAAAAAJ4w/rFs3C7ARPBA/s1600/Temp2.png)</div>

<div style="text-align: center;">**Figure 2\. A track critical learning locations**</div>

<div style="text-align: justify;">As in figure 3, after 12 generations, the vehicle tries to learn how to turn by 180° in the critical learning location B, so it modifies its behavior but in a way that makes it fail to pass through the critical location A. This is why the fitness decreases again after it has increased, and that repeats until the vehicle learns to avoid such bad behavior by itself. However, the vehicle still fails to turn by 180°, and this is why the fitness function saturates. Actually, the road is too narrow for the vehicle to learn how to achieve that tricky 180° turn in a small number of learning generations. In another experiment, I modified the track to have a wider width (30 meters width instead of 12 meters, new map is also shown in figure 4). In only 16 iterations the vehicle learned to do that tricky 180° turn and navigate through the map almost forever without colliding! (Specifically, the car travelled the whole track more than 100 times until I stopped it manually.)</div>

<div style="text-align: center;">[**![](https://3.bp.blogspot.com/-nVsTWIs2Alc/VnIt6_dxrkI/AAAAAAAAJ44/dnZRTlSdHGQ/s320/Temp3.png)**](http://3.bp.blogspot.com/-nVsTWIs2Alc/VnIt6_dxrkI/AAAAAAAAJ44/dnZRTlSdHGQ/s1600/Temp3.png)</div>

<div style="text-align: center;">**Figure 3\. Fitness function per generation for figure 3 track set-up**</div>

<div style="text-align: center;">[**![](https://2.bp.blogspot.com/-mE8BotuqOZI/VnIt7d2mdsI/AAAAAAAAJ48/E7LqmV7cTNw/s320/Temp4.png)**](http://2.bp.blogspot.com/-mE8BotuqOZI/VnIt7d2mdsI/AAAAAAAAJ48/E7LqmV7cTNw/s1600/Temp4.png)</div>

<div style="text-align: center;">**Figure 4\. Fitness function per generation for figure 3 track set-up with a wider track**</div>

<div style="text-align: center;">

<div class="separator" style="clear: both; text-align: center;"><iframe allowfullscreen="" class="YOUTUBE-iframe-video" data-thumbnail-src="https://i.ytimg.com/vi/sne69zu5gAA/0.jpg" frameborder="0" height="266" src="https://www.youtube.com/embed/sne69zu5gAA?feature=player_embedded" width="320"></iframe></div>

</div>

<div style="text-align: center;">**Video 2\. Navigation Self-learning**</div>

<div style="text-align: justify;">For the track map of figure 5, the time traveled by the vehicle before crash for each generation is shown for different rangefinder sensor number of beams. Moderate number of beams (5 beams performed best) is proven to be the better. Figure 6 shows the same information for different rangefinder sensor ranges. The higher the sensor range is proven to be the better.</div>

<div style="text-align: center;">[**![](https://1.bp.blogspot.com/-uEnNG0drxcw/VnIt8cqt3wI/AAAAAAAAJ5I/OBXbfF1gMgM/s320/Temp5.png)**](http://1.bp.blogspot.com/-uEnNG0drxcw/VnIt8cqt3wI/AAAAAAAAJ5I/OBXbfF1gMgM/s1600/Temp5.png)</div>

<div style="text-align: center;">**Figure 5\. Fitness per generation for different number of rangefinder sensor number of beams**</div>

<div style="text-align: center;">[**![](https://1.bp.blogspot.com/-uYVzQBLMFzk/VnIt9NAdINI/AAAAAAAAJ5Q/h0Ugoo1LQWE/s320/Temp6.png)**](http://1.bp.blogspot.com/-uYVzQBLMFzk/VnIt9NAdINI/AAAAAAAAJ5Q/h0Ugoo1LQWE/s1600/Temp6.png)</div>

<div style="text-align: center;">**Figure 6\. Fitness per generation for different number of rangefinder sensor ranges**</div>

<div style="text-align: justify;">It’s important to mention that to prevent vehicles from rotating around themselves, a trick that is described later (section 6) in this report is used.</div>

<span style="color: blue; font-size: large;">5- Can vehicle learn route to a specific destination?</span>

<div style="text-align: justify;">With a simple modification to the fitness function, such that the fitness function becomes the subtraction of the vehicle drive time before collision and the Euclidean distance between the vehicle position and the destination location just before collision, the vehicle easily learns its route to the destination. In my recorded video for this experiment, it took the vehicle only 7 generations to learn its route to a far destination!</div>

<div>

<div style="text-align: center;">

<div class="separator" style="clear: both; text-align: center;"><iframe allowfullscreen="" class="YOUTUBE-iframe-video" data-thumbnail-src="https://i.ytimg.com/vi/AoLIjJJr5QI/0.jpg" frameborder="0" height="266" src="https://www.youtube.com/embed/AoLIjJJr5QI?feature=player_embedded" width="320"></iframe></div>

<div class="separator" style="clear: both; text-align: center;">****Video 3\. Self-learning route to a specific destination****</div>

<div class="separator" style="clear: both; text-align: center;">[![](https://3.bp.blogspot.com/-v8fDnlle0c0/VnIt-NEv9WI/AAAAAAAAJ5Y/qBIPhCZbKVs/s320/Temp7.png)](http://3.bp.blogspot.com/-v8fDnlle0c0/VnIt-NEv9WI/AAAAAAAAJ5Y/qBIPhCZbKVs/s1600/Temp7.png)</div>

</div>

<div style="text-align: center;">**Figure 7\. Vehicle learns to decide which turn to take to reach the destination correctly**</div>

<span style="color: blue; font-size: large;">6- Self-learning Collision Avoidance Experiment</span>

<div style="text-align: justify;">Fitness for each vehicle is simply to survive. A vehicle dies and starts from a random location if it collides with track boundaries or with another vehicle. It’s important to penalize the vehicle responsible for the accident when a collision happens as shown in figure 8\. I came to that simple role: when a collision happens, ask the question: “Would crash still happen if a vehicle x is the only vehicle that moved at collision time step?”. If the answer is yes, vehicle x is a reason for that accident, and should be penalized.</div>

<div style="text-align: center;">

<div style="text-align: center;">[![](https://4.bp.blogspot.com/-mp4HOTWChzA/VnIt-tWm7LI/AAAAAAAAJ5c/G1ogOy5tW9M/s320/Temp8.png)](http://4.bp.blogspot.com/-mp4HOTWChzA/VnIt-tWm7LI/AAAAAAAAJ5c/G1ogOy5tW9M/s1600/Temp8.png)</div>

<div style="text-align: center;">****Figure 8\. Collision penalization. Two examples with two vehicles before and after the accident time step****</div>

<div style="text-align: center;"><span style="text-align: justify;"></span></div>

<div style="text-align: justify;">It is interesting to discover that vehicles started to learn bad habits to survive. Each vehicle learned to rotate around itself such that it avoids colliding with track boundaries and other vehicles! Figure 9 show such behavior. To cope with that, the fitness function is modified such that if a vehicle “gets smart” and starts to rotate around itself, it is penalized with a fitness of zero. That was a banality that is good enough for vehicles not to adopt such a bad habit. The standard deviation of vehicle position can easily detect such behavior.</div>

</div>

<div style="text-align: center;">[![](https://2.bp.blogspot.com/-5VepEx6P7_Q/VnIt_h01CPI/AAAAAAAAJ5o/CvdlGR4qncY/s320/Temp9.png)](http://2.bp.blogspot.com/-5VepEx6P7_Q/VnIt_h01CPI/AAAAAAAAJ5o/CvdlGR4qncY/s1600/Temp9.png) ****Figure 9\. Vehicles learn bad habit too!****

<div style="text-align: left;"><span style="text-align: justify;"></span></div>

<div style="text-align: left;"><span style="text-align: justify;">Eventually, vehicles learned to avoid collision. Videos 4 and 5 show the experiment results for early and late generations respectively. The fascinating thing is that no human has told the vehicles how to drive and avoid collision! The video for late generation is recorded while cars are in generations 33, 20, 12, 12, 31, 21, 18, and 14 respectively. A different replacement strategy is adopted to achieve such good performance; the new population is composed of the best 90% children chromosomes in addition to 10% of the best chromosomes from all the vehicles.</span></div>

</div>

<div>

<div style="text-align: center;">

<div class="separator" style="clear: both; text-align: center;"><iframe allowfullscreen="" class="YOUTUBE-iframe-video" data-thumbnail-src="https://i.ytimg.com/vi/8kxeuh6A--M/0.jpg" frameborder="0" height="266" src="https://www.youtube.com/embed/8kxeuh6A--M?feature=player_embedded" width="320"></iframe></div>

**Video 4\. Collision avoidance experiment for early generations**</div>

<div>

<div style="text-align: center;">

<div class="separator" style="clear: both; text-align: center;"><iframe allowfullscreen="" class="YOUTUBE-iframe-video" data-thumbnail-src="https://i.ytimg.com/vi/yg4sHO0iUJo/0.jpg" frameborder="0" height="266" src="https://www.youtube.com/embed/yg4sHO0iUJo?feature=player_embedded" width="320"></iframe></div>

****Video 5\. Collision avoidance experiment for late generations****</div>

</div>

</div>

</div>

</div>

</div>