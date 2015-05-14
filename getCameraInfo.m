function [camera_name, camera_id, resolution] = getCameraInfo(a)
camera_name = char(a.InstalledAdaptors(end));
% camera_info = imaqhwinfo(camera_name);
% camera_id = camera_info.DeviceInfo.DeviceID;
camera_id = 1;
camera_info = imaqhwinfo(camera_name,camera_id);
resolution = char(camera_info.SupportedFormats(1));
end