function outputs = Feedforward(Sample, Chromosome, Network_Arch, unipolarBipolarSelector)

    % Feed Forward
    activations = [Sample  1]; %Adding Bias Node
    startId = 0;
    for Layer = 2:length(Network_Arch)
        d1 = length(activations);
        d2 = Network_Arch(Layer);
        weights = Chromosome(startId+1 : startId+d1*d2);
        weigths = reshape(weights, d1, d2);
        activations = activations*weigths;
        
        if (unipolarBipolarSelector == 0)
            activations = 1./(1 + exp(-activations));
        else
            activations = -1 + 2./(1 + exp(-activations));
        end
        
        if (Layer ~= length(Network_Arch)) %Adding Bias
            activations = [activations 1];
        end
        startId = d1*d2;
    end
    
    outputs = activations;

end