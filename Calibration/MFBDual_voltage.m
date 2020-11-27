clear all

%----------- VARIABLE TO SET ----------
%set mice ID
mouse = {'M0882' 'M0863','M0936','M0941','M0913','M0934','M0935','M1016','M1081','M1116','M1117'};
ok_mfb = [1 1 0 1 1 1 0 0 1 1 1]; % mouse that are use in experiment
ok_dual = [0 1 0 1 1 0 0 0 1 1 1]; % mouse that are use in experiment
%set MFB voltage used during dual
voltmfbpag = [NaN NaN; 5.5 7; 3 3; 7 8.5; 4 5; NaN NaN; NaN NaN; 4.5 6; 7 3.5; 3.5 4; 3.5 7];

%----------- SAVING PARAMETERS ----------
% Outputs
dirout = [dropbox 'DataSL/Calibration/' date '/'];
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
mfbnbr(1,:) = [NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; 4; NaN; 23; NaN; ...
                 29; NaN; 29; NaN; 8; NaN; ...
                 NaN; NaN; NaN];

dualnbr(1,:) = [NaN; NaN; NaN; NaN; NaN; NaN;... 
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN];

%M0863
mfbnbr(2,:) = [NaN; NaN; 1; NaN; 3; NaN; ...
                 10; NaN; 22; NaN; 34; NaN; ...
                 36; NaN; 36; NaN; 36; NaN; ...
                 NaN; NaN; NaN];

dualnbr(2,:) = [NaN; NaN; 23; NaN; 29; NaN;  ...
                  23; NaN; 28; NaN; 13; 9;...
                  2; 3; 0; NaN; NaN; NaN;...
                  NaN; NaN; NaN];
              
%M0936
mfbnbr(3,:) = [0; NaN; 3; NaN; 14; 25; ...
                 31; 28; 26; NaN; NaN; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(3,:) = [29; 29; 31; 23; 15; 1;...  
                0; NaN; NaN; NaN; NaN; NaN; ...
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN];             

%M0941
mfbnbr(4,:) = [2; NaN; 5; 16; 1; 7; ...
                 17; 20; 11; 18; 17; 22; ...
                 24; 24; 25; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(4,:) = [24; NaN; 22; NaN; 20; NaN;...
                  25; NaN; 20; NaN; 22; NaN;... 
                  18; NaN; 14; 8; 5; 0; ...
                  NaN; NaN; NaN;];             

%M0913
mfbnbr(5,:) = [5; NaN; 3; NaN; 1; NaN; ...
                 2; NaN; 33; 25; 31; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(5,:,:) = [31; NaN; 21; NaN; 23; NaN;...
                  33; NaN; 9; NaN; 1; NaN; ...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                    NaN; NaN; NaN];  
% NOTE: see special case script for this mouse. After dual at 5V it started
% to go back even though it was aversive...

%M0934
mfbnbr(6,:) = [2; NaN; 1; NaN; 9; 16; ...
                 25; 32; 31; 32; 33; 34; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(6,:) = [NaN; NaN; NaN; NaN; NaN; NaN;... 
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN];  
%NOTE: no dual was done on this mouse. Issue with nosepoke (Marcelo).

%M0935
mfbnbr(7,:) = [7; NaN; 7; NaN; 8; NaN; ...
                 17; 23; 25; 34; 31; 27; ...
                 28; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(7,:) = [NaN; NaN; NaN; NaN; NaN; NaN;... 
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN];               
 %NOTE: no dual was done on this mouse. Issue with nosepoke (Marcelo).

%M016
mfbnbr(8,:) = [5; NaN; 3; NaN; 2; NaN; ...
                 6; 9; 12; 29; 23; 26; ...
                 23; 26; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(8,:) = [22; NaN; 20; NaN; 34; NaN;...
                  32; NaN; 29; NaN; 22; NaN;... 
                  21; 18; 13; 15; 11; 0; ...
                  2; NaN; NaN;];  

%M081
mfbnbr(9,:) = [5; NaN; 1; NaN; 3; NaN; ...
                 9; NaN; 12; 14; 16; NaN; ...
                 17; NaN; 24; 25; 29; NaN; ...
                 NaN; NaN; NaN];

dualnbr(9,:) = [32; NaN; 31; 29; 26; 32;  ...
                  25; 0; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN];
      
%M1116
mfbnbr(10,:) = [4; NaN; 5; NaN; 7; 10; ...
                 25; 33; 26; 34; NaN; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];

dualnbr(10,:) = [42; NaN; 40; 41; 37; 33;  ...
                  31; 31; 23; 22; NaN; NaN;...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN];
              
%M1117
mfbnbr(11,:) = [1; NaN; 3; NaN; 4; 5; ...
                 14; 23; 27; 33; NaN; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];

dualnbr(11,:) = [28; NaN; 27; NaN; 33; NaN;  ...
                  41; NaN; 34; NaN; 36; NaN;...
                  36; NaN; 31; 15; 4; NaN;...
                  NaN; NaN; NaN];
 
%voltage = [0 0.5 1 1.5 2 2.5 ...
%           3 3.5 4 4.5 5 5.5 ...
%           6 6.5 7 7.5 8 8.5 ...
%           9 9.5 10];
 
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