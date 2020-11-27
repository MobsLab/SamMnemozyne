function fff
clear all
%global f;

f = figure('units','pixels','position',[400,400,220,100],...
             'toolbar','none','menu','none');

% Question...         
hOld.t = uicontrol('style','text','units','pixels', ...
                'position',[20 50 180 40], ...
                'String', 'Do you wish to use the folders already selected?');

% Create yes/no checkboxes
hOld.c(1) = uicontrol('style','pushbutton','units','pixels',...
                'position',[50,15,50,30],'string','Yes','callback',@OldConc);
hOld.c(2) = uicontrol('style','pushbutton','units','pixels',...
                'position',[120,15,50,30],'string','No','callback',@NewConc);   
            
     

            
    % Pushbutton callback
    function OldConc(hObject, EventData, handles)
        disp('Yes, use old')
        delete(f)       
    end

    function NewConc(hObject, EventData, handles)
        disp('No, use new ones')
        delete(f)     
    end
    
    
    
    
end
    
    
                
% % Create yes/no checkboxes
% hOld.c(1) = uicontrol('style','checkbox','units','pixels',...
%                 'position',[30,30,50,15],'string','yes');
% hOld.c(2) = uicontrol('style','checkbox','units','pixels',...
%                 'position',[100,30,50,15],'string','no');    
 % Create OK pushbutton   
% hOld.p = uicontrol('style','pushbutton','units','pixels',...
%                 'position',[70,5,70,20],'string','OK',...
%                 'callback',@p_call);