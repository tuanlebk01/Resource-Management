function y = singleExponential(x,alpha,window_size)

n = length(x);
y = zeros(n+1,1);
y_temp = zeros(window_size + 1,1);
y(1) = x(1);
totalStep = n - window_size + 1;
for i = 1:totalStep    
        if i == 1 % first step
            for j = 2:window_size + 1
                y(j) = y(j-1) + alpha*(x(j-1) - y(j-1));
            end
        else
            y_temp(1) = x(i);
            index = 1;
            for k = i+1:i + window_size                
                y_temp(index+1) = y_temp(index) + alpha*(x(k-1) - y_temp(index));
                index = index + 1;
            end
            y(i+window_size) = y_temp(end);
        end
end
            
            
        
        
        
        
        
        
        
        
        
        
        