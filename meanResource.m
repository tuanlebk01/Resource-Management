clear all
load resourceUsage
load jobs
jobIDInJobs = jobs.jobID;
jobIDs = resourceUsage.JobID;
ram = resourceUsage.RAM;
cpu = resourceUsage.CPU;
taskIDs = resourceUsage.TaskID;

n = length(jobIDInJobs);
ramMean = [];
cpuMean = [];

for i = 1:n
    tempJobID = jobIDInJobs(i);
    counter = 0;
    % find position of jobID
    positions = find(jobIDs == tempJobID);
    if ~isempty(positions)
        firstP = positions(1);
        while(1)
            if jobIDs(firstP + counter) == tempJobID
                counter = counter + 1;
            else
                break
            end
        end
        RamMean = mean(ram(firstP:firstP + counter - 1));
        CpuMean = mean(cpu(firstP:firstP + counter - 1));
        ramMean = [ramMean RamMean];
        cpuMean = [cpuMean CpuMean];
    end    
end