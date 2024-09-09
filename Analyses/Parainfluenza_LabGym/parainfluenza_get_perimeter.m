function subStruct = parainfluenza_get_perimeter(subStruct)

    setNames = fieldnames(subStruct);
    try
        load('F:\LabGym\PARAINFLUENZA PROJECT\matlab\perimeterAll.mat');
        subStruct.set1.prePerim = perimeterAllPreSet1;
        subStruct.set1.postPerim = perimeterAllPostSet1;
        subStruct.set2.prePerim = perimeterAllPreSet2;
        subStruct.set2.postPerim = perimeterAllPostSet2;
    catch
        for set = 1:numel(setNames)
            setName = setNames{set};
            for subNo = 1:numel(subStruct.(setName).names)
                prePath = subStruct.(setName).prePath{subNo};
                postPath = subStruct.(setName).postPath{subNo};
                subStruct.(setName).prePerim = get_perimeter(prePath);
                subStruct.(setName).postPerim = get_perimeter(postPath);
            end
        end
    end
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