function subStruct = parainfluenza_get_perimeter(subStruct)

try
    load('F:\LabGym\PARAINFLUENZA PROJECT\matlab\perimeterAll.mat');
catch
end


function innerPerim = get_perimeter(filePath)
% inner perimeter
    f = figure;
    hold on
    vid = VideoReader(fullfile(filePath.folder, filePath.name));
    frame = read(vid, 100);
    perimAccepted = false;
    while ~perimAccepted
        clf(f)
        imshow(frame, 'Border', 'tight')
        ax = gca;
        disableDefaultInteractivity(ax)
        [outerPerim, innerPerim] = parainfluenza_perimeters(f);
        hold on
        rectangle('Position', outerPerim, 'EdgeColor', 'k')
        rectangle('Position', innerPerim, 'EdgeColor', 'r')
        qFig = uifigure;
        qAns = uiconfirm(qFig, "Accept perimeters?", "Bounding Boxes");
        perimAccepted = strcmp(qAns, "OK");
        close(qFig)
    end    
    close(f)
end