frames = 200;%Total frames
saturability = 0.18;
size = 100;%Object size

sumAngle = zeros(1,frames);
sumPosition = zeros(2,frames);

a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);
vid = videoinput(camera_name, camera_id, format);

% Set the properties of the video object
set(vid, 'FramesPerTrigger', 1);
set(vid,'TriggerRepeat',Inf);
set(vid, 'ReturnedColorspace', 'rgb');
triggerconfig(vid,'manual');
% vid.FrameGrabInterval = 10;

%start the video aquisition here
start(vid)

prev = [0,1];
i=1;

while(vid.FramesAcquired<=frames)
    trigger(vid);
    data = getdata(vid);
    diff_im = imsubtract(data(:,:,1), rgb2gray(data));
    %   diff_im = rgb2gray(data);
    diff_im = medfilt2(diff_im, [3 3]);
    diff_im = im2bw(diff_im,saturability);
    
    diff_im = bwareaopen(diff_im,size);
    bw = bwlabel(diff_im, 8);
    bw = logical(bw);
    
    stats = regionprops(bw, 'BoundingBox', 'Centroid','Area');
    imshow(data)
    
    hold on
    
    if (length(stats)==2)
        for object = 1:length(stats)
            bb = stats(object).BoundingBox;
            bc = stats(object).Centroid;
            rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
            plot(bc(1),bc(2), '-m+')
            a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
            set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        end
        [temp,sortResult] = sort([stats.Area]);
        result = stats(sortResult);
        vector = result(1).Centroid - result(2).Centroid;
        vectorf = vector ./ norm(vector);
        
        angle = acos(prev*vectorf');
        crossVector = cross([prev,0],[vectorf,0]);
        if (crossVector(3) < 0)
            angle = -angle;
        end
        position = result(2).Centroid;
        
        prev = vectorf;
        sumAngle(vid.FramesAcquired) = angle;
        sumPosition(:,vid.FramesAcquired) = position;
        
    end
    
    hold off
    flushdata(vid);
end

stop(vid);
flushdata(vid);
delete(vid);


sumAngle = sumAngle ./ pi;
figure(2)
hold on
plot(sumPosition(1,:),sumPosition(2,:),0,0,320,176)
hold off
figure(3)
plot(1:frames+1,sumAngle,1:frames+1,0.5*ones(1,1+frames),1:frames+1,-0.5*ones(1,1+frames),1:frames+1,zeros(1,1+frames))
clear all