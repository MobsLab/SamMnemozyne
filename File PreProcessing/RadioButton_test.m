hOld.f = figure('units','pixels','position',[200,200,150,50],...
             'toolbar','none','menu','none','title','test');
% Create yes/no checkboxes
hOld.c(1) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,30,50,15],'string','yes');
hOld.c(2) = uicontrol('style','checkbox','units','pixels',...
                'position',[90,30,50,15],'string','no');    
% Create OK pushbutton   
hOld.p = uicontrol('style','pushbutton','units','pixels',...
                'position',[40,5,70,20],'string','OK',...
                'callback',@p_call);
    % Pushbutton callback
    function p_call(varargin)
        vals = get(hOld.c,'Value');
        checked = find([vals{:}]);
        if isempty(checked)
            checked = 'none';
        end
        disp(checked)
    end
end