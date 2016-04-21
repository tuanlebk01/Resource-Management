function [fileName,numberLines] = readlines(i)
    fileName = sprintf('part-00%.3i-of-00500.csv', i-1);
    fid = fopen(fileName, 'rb');
    %# Get file size.
    fseek(fid, 0, 'eof');
    fileSize = ftell(fid);
    frewind(fid);
    %# Read the whole file.
    data = fread(fid, fileSize, 'uint8');
    %# Count number of line-feeds and increase by one.
    numberLines = sum(data == 10) + 1;
    fclose(fid);

    %taskID = [taskID;TaskID];
%jobID = [jobID;JobID];
end