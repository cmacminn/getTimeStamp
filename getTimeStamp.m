function t = getTimeStamp(path_str)
    % Get the timestamp of an image file using EXIF metadata.
    % 
    % INPUTS
    %   path_str: String specifying the (relative or absolute) path to the image, including the name and extension of the file (e.g., '~/Desktop/text.jpg'). Not case sensitive.
    % 
    % OUTPUTS
    %   t: Timestamp of target image in seconds. Specifically, this is the number of seconds since the beginning of the most recent calendar month.
    % 
    % HISTORY
    % 2012-??-?? Created by CWM
    % 2014-02-27 Modified by CWM
    %   - Added detailed comments on inputs and outputs.
    % 2014-06-06 Modified by CWM
    %   - Added error handling
    % 2014-06-13 Modified by CWM
    %	- Added comments on expected format of DateTime and FileModDate
    %   - Minor formatting tweaks
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The MIT License (MIT)
    % 
    % Copyright (c) 2014 Christopher W. MacMinn
    % 
    % Permission is hereby granted, free of charge, to any person obtaining a copy
    % of this software and associated documentation files (the "Software"), to deal
    % in the Software without restriction, including without limitation the rights
    % to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    % copies of the Software, and to permit persons to whom the Software is
    % furnished to do so, subject to the following conditions:
    % 
    % The above copyright notice and this permission notice shall be included in
    % all copies or substantial portions of the Software.
    % 
    % THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    % IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    % FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    % AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    % LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    % OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    % THE SOFTWARE.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Set a fallback value for t
    t = NaN;
    
    % Error handling
    try
        tt = imfinfo(path_str);
    catch
        % If IMFINFO failed, then either the path is wrong or the file is not an image file.
        try
            % Check the file type
            typestr = finfo(path_str);
        catch
            % If FINFO failed, the path is wrong.
            error(['Could not file a file at ''' path_str '''. Please check the path and try again.'])
        end
        % If FINFO succeeded, the file is not an image file.
        error(['The file ''' path_str ''' has type ''' typestr ''' and is not recognized by IMFINFO.'])
    end
    
    % If we made it this far, IMFINFO found a file that it recognizes. Try to read the timestamp.
    % NOTE: Assumes that DateTime is a string in the format 'YYYY:MM:DD HH:MM:SS' (e.g., '2013:05:20 14:43:10')
    %       whereas FileModDate is a string in the format 'DD-M*-YYYY HH:MM:SS' (e.g., '20-May-2013 14:43:10')
    if isfield(tt,'DigitalCamera')
        % Use EXIF data if available
        % Convert DateTimeOriginal to a number in seconds
        % ** NOTE: This will fail if the month rolls over.
        t = 24*60*60*str2num(tt.DigitalCamera.DateTimeOriginal(9:10))... % day
             + 60*60*str2num(tt.DigitalCamera.DateTimeOriginal(12:13))...% hour
                + 60*str2num(tt.DigitalCamera.DateTimeOriginal(15:16))...% minute
                   + str2num(tt.DigitalCamera.DateTimeOriginal(18:19));  % second
        % Add the subsecond from SubsecTimeOriginal if available
        if isfield(tt.DigitalCamera,'SubsecTimeOriginal')
            t = t + str2num(['0.' tt.DigitalCamera.SubsecTimeOriginal]);
        end
    elseif isfield(tt,'DateTime')
        % Otherwise, check for a timestamp
        t = 24*60*60*str2num(tt.DateTime(9:10))... % day
             + 60*60*str2num(tt.DateTime(12:13))...% hour
                + 60*str2num(tt.DateTime(15:16))...% minute
                   + str2num(tt.DateTime(18:19));  % second
    else
        % Otherwise, use the file mod date
        t = 24*60*60*str2num(tt.FileModDate(1:2))...  % day
             + 60*60*str2num(tt.FileModDate(13:14))...% hour
                + 60*str2num(tt.FileModDate(16:17))...% minute
                   + str2num(tt.FileModDate(19:20));  % second
    end
    
    % If timestamp was not set, error.
    if isnan(t)
        error(['Found an image, but could not get a timestamp.'])
    end
    
end