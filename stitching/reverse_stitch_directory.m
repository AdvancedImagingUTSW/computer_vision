
function reverseBigStitchDirectory(dataDirectory);
dataDirectory = ('/project/bioinformatics/shared/Dean/1019_11_25_stitchingTutorial/Cell11');
cd(dataDirectory);

for i = 1:1:12
    directoryName = ['position ' num2str(i)]; 
    mkdirRobust(directoryName);
    
    oldName = ['1_CH00_' num2str(i) '.tif'];
    newName = '1_CH00_000000.tif';
    movefile(oldName,fullfile(directoryName,newName));
    
    oldNumber = sprintf('%06d',i);
    oldName = ['AcqInfo_' num2str(oldNumber) '.txt'];
    newName = 'AcqInfo.txt';
    movefile(fullfile('acquisitionInfo',oldName),newName);
end

%%
for i = 1:1:12
    oldNumber = sprintf('%06d',i);
    oldName = ['AcqInfo_' num2str(oldNumber) '.txt'];
    newName = 'AcqInfo.txt';
    movefile(fullfile('acquisitionInfo',oldName),...
        fullfile(['position ' num2str(i)],newName));
end
