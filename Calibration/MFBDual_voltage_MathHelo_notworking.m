clear all

%% DUMMY DATA

%----------- VARIABLE TO SET ----------
%set mice ID
mouse = {'M1138'};
ok_mfb = [1]; % mouse that are use in experiment
ok_dual = [1]; % mouse that are use in experiment
%set MFB voltage used during dual
voltmfbpag = [4.5 10];

%----------- SAVING PARAMETERS ----------
% Outputs
dirout = [dropbox '/DataSL/Calibration/MathHelo/' date '/'];
if ~exist(dirout, 'dir')
    mkdir(dirout);
    if ismac
        disp('Creating folder (mac version)');
    elseif isunix
        disp('Creating folder (linux version)');
        system(['sudo chown mobs /' dirout]);
    else
        disp('Creating folder (pc version)');
    end
end
sav=1;      % Do you want to save a figure? Y=1; N=0


%-----------hardcoded DATA ----------
voltage = [0 0.5 1 1.5 2 2.5 ...
           3 3.5 4 4.5 5 5.5 ...
           6 6.5 7 7.5 8 8.5 ...
           9 9.5 10];

%M0882
mfbnbr(1,:) = [6; NaN; 4; NaN; 2; NaN; ...
                 3; NaN; 1; NaN; 2; NaN; ...
                 4; NaN; 0; NaN; 1; NaN; ...
                 NaN; NaN; NaN];

dualnbr(1,:) = [33; NaN; NaN; NaN; 35; NaN;... 
                NaN; NaN; 33; NaN; NaN; NaN;...
                20; NaN; NaN; NaN; 20; NaN;...
                24; NaN; 23];

 
% Get normalized value for voltage 
for i=1:length(mouse)
    %mfb   
    if ok_mfb(i)
        idv = find(sum(~isnan(mfbnbr(i,:)),1) > 0, 1 , 'last');
        maxv(i)=voltage(idv);     
        norm_volt(i,1:length(voltage))=voltage/maxv(i);
    end
    %dual
    if ok_dual(i)
        idvd = find(sum(~isnan(dualnbr(i,:)),1) >0, 1 , 'last');
        if ~isempty(idvd)
            maxdv(i)=voltage(idvd);     
            norm_dvolt(i,1:length(voltage))=voltage/maxdv(i);
        else
            norm_dvolt(i,1:length(voltage))= NaN;
        end
    end
end 

%%
%--------------------------------------------------------------------------
%                   M F B   b y   M O U S E
%--------------------------------------------------------------------------
% MFB
for i=1:length(mouse)
    if ok_mfb(i)
        figure2(1,'Position',[0 50 600 400])
            y = mfbnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on

        ylim([0 42]);
        xlim([0 8.5]);
        title(['Mouse ' mouse{i} ': Self-stimulation during MFB calibration'])
        xlabel('MFB voltage') 
        ylabel('Nbr of self-stimulation')
        
        print([dirout '/fig_mfbcalib_' mouse{i}], '-dpng', '-r300');
        if ismac
            disp('Saving to mac');
        elseif isunix
            system(['sudo chown mobs ' dirout 'fig_mfbcalib_' mouse{i} '.png']);
        end
        
    end
    if ok_dual(i)
        figure2(1,'Position',[0 50 600 400])
            y = dualnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on
        ylim([0 42]);
        xlim([0 8.5]);

        title(['Mouse ' mouse{i} ': Self-stimulation during dual stimultion (MFB+PAG)'])
        xlabel('PAG voltage') 
        ylabel('Nbr of self-stimulation')

        print([dirout '/fig_dualcalib_' mouse{i}], '-dpng', '-r300');
    end
end

%--------------------------------------------------------------------------
%                            M F B
%--------------------------------------------------------------------------
% MFB
figure2(1,'Position',[0 50 600 400])
    for i=1:length(mouse)
        if ok_mfb(i)
            y = mfbnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on
        end
    end
    ylim([0 43]);
    xlim([0 8.5]);
    title('Self-stimulation during MFB calibration')
    xlabel('MFB voltage') 
    ylabel('Nbr of self-stimulation')
    legend(mouse{find(ok_mfb)}, 'Location','southeast')
 
    print([dirout '/fig_mfbcalib'], '-dpng', '-r300');

%Normalized MFB
figure2(1,'Position',[0 50 600 400])
    for i=1:length(mouse)
        if ok_mfb(i)
            y = mfbnbr(i,:); %nbr stim
            x = norm_volt(i,:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o','LineWidth',.5)
            hold on
        end
    end
    ylim([0 43]);
%     xlim([0 1]);
    title('Self-stimulation during MFB calibration')
    xlabel('Normalized MFB voltage') 
    ylabel('Nbr of self-stimulation')
    legend(mouse{find(ok_mfb)}, 'Location','southeast')
 
    print([dirout '/fig_mfbcalib_norm'], '-dpng', '-r300');    

    
%--------------------------------------------------------------------------
%                         D U A L 
%--------------------------------------------------------------------------
% set legend text
ii=0;
for i=1:length(mouse)
    if ok_dual(i)
        ii=ii+1;
        legtxt{ii} = [mouse{i} ' - MFB: ' num2str(voltmfbpag(i,1)) 'V'];
    end
end

% DUAL
figure2(1,'Position',[0 50 600 400])
    for i=1:length(mouse)
        if ok_dual(i)
            y = dualnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on
        end
    end
    ylim([0 43]);
    xlim([0 8.5]);
    
    title('Self-stimulation during dual stimultion (MFB+PAG)')
    xlabel('PAG voltage') 
    ylabel('Nbr of self-stimulation')
    legend(legtxt,'Location','northeast')
 
    print([dirout '/fig_dualcalib'], '-dpng', '-r300');
    
% %Normalized Dual
figure2(1,'Position',[0 50 600 400])
    for i=1:length(mouse)
        if ok_dual(i)
            y = dualnbr(i,:); %nbr stim
            x = norm_dvolt(i,:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on
        end
    end
    ylim([0 43]);
%     xlim([0 1]);
    title('Self-stimulation during dual calibration')
    xlabel('Normalized PAG voltage') 
    ylabel('Nbr of self-stimulation')
    legend(legtxt,'Location','northeast')
 
    print([dirout '/fig_dualcalib_norm'], '-dpng', '-r300');      