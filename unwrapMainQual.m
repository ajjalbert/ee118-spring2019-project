function phaseData = unwrapMainQual(WrappedData,varargin)

%   UNWRAPMAINQUAL Use mainqual algorithm to unwrap 2-dimensional phase data.
%
%   Author:         M.Rinehart
%   Affiliation:    Duke University BIOS Lab
%   Date:           2011
% 
%   Unwrapped = unwrapMainQual(WrappedData) for an arbitrarily sized set of
%   wrapped phase values (between -pi and pi), uses the quality-map guided
%   method to unwrap the phase.
%   
%   OPTIONS
%   
%       'version'   'mainqual32_icl_4_1' (default)
%                   'mainqual32_icl_4_2'
%                   'mainqual32_icl_3'
%                   'mainqual32'
%                   'mainqual64'
%                   (NOT WORKING) 'mainqual'
%   
%       'IOID'      Any (unique) string identifier for the I/O filenames.
%       
%       'mode'      'normal' (default)  no output text from mainqual
%                   'debug'             mainqual output displays in window
%
%       'mask'      'maskname' takes a binary matrix, which must be the
%                   same size as the input WrappedData as a quality map.
%   
%   
%   From Ghiglia & Pritt book: "Two-Dimensional Phase Unwrapping: Theory,
%   Algorithms, and Software" ISBN: 0-471-24935-1
%
%   See also UNWRAP, ANGLE, ABS.

try

    % SET THIS PATH VARIABLE IF THE LOCATION OF THIS TOOLBOX EVER CHANGES!
%     PathVar = 'W:\Shwetadwip\Code\unwrapping\mainqual\';
    PathVar = 'C:\Users\Andrew\Documents\MATLAB\EE118\Final_Project\unwrapping\mainqual\';
    % Default input options
    versionOPT = 'mainqual32_icl_4_1';
    IOIDOPT = num2str(randi(1000));
    modeOPT = 'normal';
    maskOPT = 0;
    options = [0 0 0 0];

    if (~isempty(varargin))
        for c=1:2:length(varargin)
            switch varargin{c}
                case {'version'}
                    options(1)=1;
                    versionOPT = varargin{c+1};
                case {'IOID'}
                    options(2)=1;
                    IOIDOPT = num2str(varargin{c+1});
                case {'mode'}
                    options(3)=1;
                    modeOPT = varargin{c+1};
                case {'mask'}
                    options(4)=1;
                    maskOPT = 1;
                    QualityMask = varargin{c+1};
                    if size(QualityMask) ~= size(WrappedData);
                        error('Mask and phase data sizes don''t match.  Try again.');
                    end;
                otherwise
                error(['Invalid optional argument, ', ...
                    varargin{c}]);
            end % switch
        end % for
    end % if

    % Set mainqual output suppression here.  Add any other debugging outputs
    % here too...
    if strcmp(modeOPT,'debug');
        outputRouting = '';
    elseif strcmp(modeOPT,'normal');
        outputRouting = '>nul 2>nul';
    else
        error('Mode choice is invalid.  Please try again, either with ''normal'' or ''debug''. ');
    end;

    WrappedName = [PathVar 'wrapped' IOIDOPT '.dat'];
    UnwrappedName = [PathVar 'unwrapped' IOIDOPT '.surf'];
    MaskName = [PathVar 'maskFcn' IOIDOPT '.dat'];
    sizes = size(WrappedData);

    WrappedDataFID = fopen(WrappedName,'w+');
    fwrite(WrappedDataFID,WrappedData,'float32');
    fclose(WrappedDataFID);

    if maskOPT == 1;
        MaskFID = fopen(MaskName,'w+');
        fwrite(MaskFID,QualityMask,'uint8');
        fclose(MaskFID);
        eval(['!' PathVar versionOPT '.exe -input ' WrappedName ' -format float -output ' UnwrappedName ' -bmask ' MaskName ' -xsize ',num2str(sizes(1)),' -ysize ',num2str(sizes(2)),' -mode min_grad' outputRouting])
    else
        eval(['!' PathVar versionOPT '.exe -input ' WrappedName ' -format float -output ' UnwrappedName ' -xsize ',num2str(sizes(1)),' -ysize ',num2str(sizes(2)),' -mode min_grad' outputRouting])
    end;

    UnwrappedFID = fopen(UnwrappedName, 'r');
    out = fread(UnwrappedFID,sizes(1).*sizes(2),'float32');
    fclose(UnwrappedFID);

    phaseData = reshape(out,sizes(1),sizes(2));

    if maskOPT == 1;
        delete(WrappedName,UnwrappedName,MaskName);
    else
        delete(WrappedName,UnwrappedName);
    end;
    
catch ERRID
    
    disp(ERRID);
    
    phaseData = 0;
end;