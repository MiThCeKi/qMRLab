function RefreshColorMap(handles)
val  = get(handles.ColorMapStyle, 'Value');
maps = get(handles.ColorMapStyle, 'String'); 
if strcmp(maps{val}, 'MTSATmap') ~= 0 
    MTSATmap = getappdata(0, 'MTSATmap');
    colormap(MTSATmap);
else 
    colormap(maps{val});
end
colorbar('location', 'South', 'Color', 'white');
min = str2double(get(handles.MinValue, 'String'));
max = str2double(get(handles.MaxValue, 'String'));
caxis([min max]);