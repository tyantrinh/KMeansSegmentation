function varargout = kMean(varargin)
% KMEAN MATLAB code for kMean.fig
%      KMEAN, by itself, creates a new KMEAN or raises the existing
%      singleton*.
%
%      H = KMEAN returns the handle to a new KMEAN or the handle to
%      the existing singleton*.
%
%      KMEAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KMEAN.M with the given input arguments.
%
%      KMEAN('Property','Value',...) creates a new KMEAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kMean_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kMean_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kMean

% Last Modified by GUIDE v2.5 05-Dec-2019 10:13:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kMean_OpeningFcn, ...
                   'gui_OutputFcn',  @kMean_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before kMean is made visible.
function kMean_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kMean (see VARARGIN)

% Choose default command line output for kMean
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
clear all;
reset;

% UIWAIT makes kMean wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = kMean_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
displayResult;


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global X; % original image
global hAxes1;

% open an image
[FileName,PathName] = uigetfile('*.bmp;*.tif;*.jpg;*.hdf','Select the image file');
if ispc
    FullPathName = [PathName,'\',FileName];
elseif ismac
    FullPathName = [PathName,'/',FileName];
elseif isunix
    FullPathName = [PathName,'/',FileName];
else
    FullPathName = [PathName,'\',FileName];
end
X = imread(FullPathName);

%display the original image
set(gcf, 'CurrentAxes', hAxes1);
imshow(X);

% display the result image
displayResult;

function reset
global hAxes1;
global hAxes2;

if (isempty(hAxes1))
    hAxes1 = findobj(gcf,'Tag', 'axes1');
end
if (isempty(hAxes2))
    hAxes2 = findobj(gcf,'Tag', 'axes2');
end

set(gcf, 'CurrentAxes', hAxes1);
imshow(1);
set(gcf, 'CurrentAxes', hAxes2);
imshow(1);
return;

function displayResult

global X;
global hAxes2;

X = im2double(X);
Xflat = reshape(X,size(X,1)*size(X,2),3);

% Slider object
KSlider = findobj(gcf, 'Tag', 'slider1');
iterativeSlider = findobj(gcf, 'Tag', 'slider2');

% Slider value
K = round(get(KSlider,'Value'));
iterative = get(iterativeSlider,'Value');
iteration = round(iterative);

% Generate Superpixel (Preprocessing)
randArray = rand(K,1);
row = size(Xflat,1);
SP = Xflat(ceil(randArray * row), :); % Specify superpixel 
delta = zeros(row, K+1);

% Processing (Catagorizing pixels based on intensity and distance)
% distance is the magnitude of the change in supercluster
for i = 1:iteration
    for j = 1:row
        for k = 1:K
            delta(j,k) = norm(Xflat(j,:) - SP(k,:));
        end
        [D, ind] = min(delta(j,1:K)); 
        delta(j, K+1) = ind;    % Stores index corresponding to min
    end
    
    for j = 1:K
        cluster = (delta(:,K+1) == j);
        SP(i,:) = mean(Xflat(cluster,:)); % Update new SP
        
    end
end

% Post processing (Replace each pixel with the supercluster
Y = zeros(size(Xflat));
for i = 1:K
    index = find(delta(:,K+1) == i);
    Y(index,:) = repmat(SP(i,:),size(index,1),1);
end

% Output image
imOut = reshape(Y,size(X,1),size(X,2),3);

set(gcf, 'CurrentAxes', hAxes2);
imshow(imOut);
return

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
displayResult;


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
