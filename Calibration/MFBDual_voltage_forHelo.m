clear all

%----------- VARIABLE TO SET ----------
%set mice ID
mouse = {'M0941','M016'};
ok_mfb = [1 1]; % mouse that are use in experiment
ok_dual = [1 1]; % mouse that are use in experiment
%set MFB voltage used during dual
voltmfbpag = [7 8.5; 4.5 9];
screen = 1;

%----------- SAVING PARAMETERS ----------
% Outputs
dirout = [dropbox '/DataSL/Calibration/Special/' date '/'];
if ~exist(dirout, 'dir')
    mkdir(dirout);
end
sav=1;      % Do you want to save a figure? Y=1; N=0


%-----------hardcoded DATA ----------
voltage = [0 0.5 1 1.5 2 2.5 ...
           3 3.5 4 4.5 5 5.5 ...
           6 6.5 7 7.5 8 8.5 ...
           9 9.5 10];

              
% %M0936
% mfbnbr(3,:) = [0; NaN; 3; NaN; 14; 25; ...
%                  31; 28; 26; NaN; NaN; NaN; ...
%                  NaN; NaN; NaN; NaN; NaN; NaN; ...
%                  NaN; NaN; NaN];
% dualnbr(3,:) = [29; 29; 31; 23; 15; 1;...  
%                 0; NaN; NaN; NaN; NaN; NaN; ...
%                 NaN; NaN; NaN; NaN; NaN; NaN;...
%                 NaN; NaN; NaN];             
% % dualnbr(2,:,:) = [0 29; 0.5 29; 1 31; 1.5 23; 2 15; ...
% %                   2.5 1; 3 0; NaN NaN; NaN NaN; NaN NaN; ...
% %                   NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN];

%M0941
mfbnbr(1,:) = [2; NaN; 5; 16; 1; 7; ...
                 17; 20; 11; 18; 17; 22; ...
                 24; 24; 25; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(1,:) = [24; NaN; 22; NaN; 20; NaN;...
                  25; NaN; 20; NaN; 22; NaN;... 
                  18; NaN; 14; 8; 5; 0; ...
                  NaN; NaN; NaN;];             
% dualnbr(3,:,:) = [0 24; 1 22; 2 20; 3 25; 4 20;  ...
%                   5 22; 6 18; 7 14; 7.5 8; 8 5; ...
%                   8.5 0; NaN NaN; NaN NaN; NaN NaN; NaN NaN];


%M016
mfbnbr(2,:) = [5; NaN; 3; NaN; 2; NaN; ...
                 6; 9; 12; 29; 23; 26; ...
                 23; 26; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(2,:) = [22; NaN; 20; NaN; 34; NaN;...
                  32; NaN; 29; NaN; 22; NaN;... 
                  21; 18; 13; 15; 11; 0; ...
                  2; NaN; NaN;];  
 
voltage = [0 0.5 1 1.5 2 2.5 ...
           3 3.5 4 4.5 5 5.5 ...
           6 6.5 7 7.5 8 8.5 ...
           9 9.5 10];
 
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
        figure2(screen,'Position',[1 50 600 400])
            y = mfbnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on

        ylim([0 40]);
        xlim([0 8.5]);
        title(['Mouse ' mouse{i} ': Self-stimulation during MFB calibration'])
        xlabel('MFB voltage') 
        ylabel('Nbr of self-stimulation')

        print([dirout '/fig_mfbcalib_' mouse{i}], '-dpng', '-r300');
    end
    if ok_dual(i)
        figure2(screen,'Position',[1 50 600 400])
            y = dualnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on
        ylim([0 40]);
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
figure2(screen,'Position',[1 50 600 400])
    for i=1:length(mouse)
        if ok_mfb(i)
            y = mfbnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on
        end
    end
    ylim([0 40]);
    xlim([0 8.5]);
    title('Self-stimulation during MFB calibration')
    xlabel('MFB voltage') 
    ylabel('Nbr of self-stimulation')
    legend(mouse{find(ok_mfb)}, 'Location','southeast')
 
    print([dirout '/fig_mfbcalib'], '-dpng', '-r300');

%Normalized MFB
figure2(screen,'Position',[1 50 600 400])
    for i=1:length(mouse)
        if ok_mfb(i)
            y = mfbnbr(i,:); %nbr stim
            x = norm_volt(i,:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o','LineWidth',2)
            hold on
        end
    end
    ylim([0 40]);
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
figure2(screen,'Position',[1 50 600 400])
    for i=1:length(mouse)
        if ok_dual(i)
            y = dualnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o')
            hold on
        end
    end
    ylim([0 40]);
    xlim([0 8.5]);
    
    title('Self-stimulation during dual stimultion (MFB+PAG)')
    xlabel('PAG voltage') 
    ylabel('Nbr of self-stimulation')
    legend(legtxt,'Location','northeast')
 
    print([dirout '/fig_dualcalib'], '-dpng', '-r300');
    
% %Normalized Dual
figure2(screen,'Position',[1 50 600 400])
    for i=1:length(mouse)
        if ok_dual(i)
            y = dualnbr(i,:); %nbr stim
            x = norm_dvolt(i,:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o','LineWidth',2)
            hold on
        end
    end
    ylim([0 40]);
%     xlim([0 1]);
    title('Self-stimulation during dual calibration')
    xlabel('Normalized PAG voltage') 
    ylabel('Nbr of self-stimulation')
    legend(legtxt,'Location','northeast')
 
    print([dirout '/fig_dualcalib_norm'], '-dpng', '-r300');      