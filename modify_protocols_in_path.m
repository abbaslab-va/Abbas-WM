function modify_protocols_in_path(bpodDir)
%Run this to manage your local bpod script directories to cut down on file
%bloat in the selection menu. Do not relocate this script from the
%directory where you cloned the Abbas-WM repository. 
%
%The optional parameter bpodDir allows you to specify the path bpod uses to
%store behavioral scripts. Otherwise, the user selects it from a folder.

cd(fileparts(mfilename('fullpath')))        %Change to directory where this repository was cloned
if ~exist('bpodDir', 'var')
    bpodDir = uigetdir('', 'Select the bpod repository to rearrange');
end
files = dir;
filenames = {files.name};
dotIndexed = cellfun(@(x) x(1) == '.', filenames);
isParentFolder = [files.isdir] & ~dotIndexed;
parentFolders = find(isParentFolder);
parentNames = {files(parentFolders).name};
%Choose desired task parent folders whose children will be included
parentNamesIndex = listdlg('PromptString', {'Select the tasks to include. '...
    , 'Select multiple using CTRL. ', ''}, 'ListString', parentNames);
uAnswer = questdlg({'Are you sure you wish to proceed?', 'All files in the behavioral script directory will be deleted before remapping.'},...
    'Confirm delete', 'Yes', 'No', 'No');
if strcmp(uAnswer, 'No')
    return
end
% Delete all items in the local bpod repository to repopulate from git repo
cd(bpodDir)
delete *
bpodFolders = dir;
bpodFolderNames = {bpodFolders.name};
bpodDotIndexed = cellfun(@(x) x(1) == '.', bpodFolderNames);
isBpodLocalFolder = ~bpodDotIndexed;
bpodLocalFolders = find(isBpodLocalFolder);
bpodParentFolderNames = {bpodFolders(bpodLocalFolders).name};
for del = 1:numel(bpodParentFolderNames)
    rmdir(bpodParentFolderNames{del}, 's')
end
% Repopulate from chosen items in git repo
cd(fileparts(mfilename('fullpath')))        %Change to directory where this repository was cloned
for d = 1:numel(parentNamesIndex)
    copyfile(fullfile(pwd, parentNames{parentNamesIndex(d)}), bpodDir);
end