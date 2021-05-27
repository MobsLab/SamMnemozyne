clear all

%----------- VARIABLE TO SET ----------
%set mice ID
mouse = {'M0882','M0863','M0936','M0941','M0913','M0934','M0935','M1016', ...
         'M1081','M1116','M1117','M1161','M1162','M1168','M1182','M1199'};
% full set     
ok_mfb  = [1 0 0 1 0 0 0 0 0 0 1 1 1 1 0 1]; % mouse that are use in experiment
ok_dual = [0 0 0 1 0 0 0 0 0 0 1 1 1 1 0 1]; % mouse that are use in experiment  
% % only 
% ok_mfb =  [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % mouse that are use in experiment
% ok_dual = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0]; % mouse that are use in experiment
%set MFB voltage used during dual & exp pag voltage
voltmfbpag = [6 3.5; 5 5.5; 3 3; 7 6; 4 5; NaN NaN; NaN NaN; 4.5 6; ...
              7 3.5; 3.5 4; 3.5 7; 3 4; 3.5 4.5; 3.5 5; 2.5 5; 3.5 5.5];
          
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

%M1161
mfbnbr(12,:) = [6; NaN; 4; NaN; 17; 25; ...
                 21; 23; 27; 25; NaN; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];

dualnbr(12,:) = [25; 25; 18; 9; 6; 3;  ...
                  3; NaN; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN];              
 
%M1162
mfbnbr(13,:) = [0; NaN; NaN; NaN; 7; NaN; ...
                 9; 11; 14; 21; NaN; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];

dualnbr(13,:) = [41; NaN; 33; NaN; 7; NaN;  ...
                  1; NaN; 1; NaN; NaN; NaN;...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN];
 
%M1168
mfbnbr(14,:) = [3; NaN; 3; NaN; 16; 20; ...
                 24; 33; 20; 21; NaN; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];

dualnbr(14,:) = [33; NaN; 30; NaN; 28; NaN;  ...
                  16; 15; 10; 8; 3; NaN;...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN];              
 
%M1182
mfbnbr(15,:) = [7; NaN; 10; NaN; 8; NaN; ...
                 16; 18; 30; 32; 33; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];

dualnbr(15,:) = [31; NaN; 23; 32; 35; NaN;  ...
                  4; 1; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN];  
%M1199
mfbnbr(16,:) = [5; NaN; 8; NaN; 5; NaN;... 
                3; NaN; 30; 37; 35; NaN;...
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN]; 

dualnbr(16,:) = [34; NaN; 35; NaN; 11; 2;  ...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
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

% set colors
% % Define the two colormaps.
% cmap1 = copper(size(dualnbr,1));
% cmap2 = copper(size(dualnbr,1));
% % Combine them into one tall colormap.
% combinedColorMap = [cmap1; cmap2];
% % Pick rows at random.
% randomRows = randi(size(combinedColorMap, 1), [size(dualnbr,1), 1]);
% % Extract the rows from the combined color map.
% randomColors = combinedColorMap(randomRows, :);

randomColors = jet(size(dualnbr,1));


% --------------------------------------------------------------------------
%                   M F B   b y   M O U S E
% --------------------------------------------------------------------------
% MFB
for i=1:length(mouse)
    if ok_mfb(i) 
        supertit = [mouse{i} ': Self-stimulation during MFB calibration'];
        figure2(1,'Color',[1 1 1], 'rend','painters', ...
            'pos',[10 10 800 1000],'Name', supertit, 'NumberTitle','off');
        
%         figure2(1,'Position',[0 50 600 400])
            y = mfbnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);
            subplot(211)
                plot(x(idx),y(idx),'-o')
                hold on
                if ~isnan(voltmfbpag(i,1))
    %                 plot((find(voltage==voltmfbpag(i,1))-1)/2,y(find(voltage==voltmfbpag(i,1))),'-s','MarkerSize',10,...
    %                     'MarkerEdgeColor','red',...
    %                     'MarkerFaceColor',[1 .6 .6])
                    xline((find(voltage==voltmfbpag(i,1))-1)/2, ...
                        'Color','g','LineWidth',2);
                    hold on
                end

                ylim([0 42]);
                xlim([0 8.5]);
                title(['Mouse ' mouse{i} ': Self-stimulation during MFB calibration'])
                xlabel('MFB voltage') 
                ylabel('Nbr of self-stimulation')
                makepretty_erc
        if ok_dual(i)
                subplot(212)
        %         figure2(1,'Position',[0 50 600 400])
                    y = dualnbr(i,:); %nbr stim
                    x = voltage(:); %voltage
                    idx = ~any(isnan(y),1);

                    plot(x(idx),y(idx),'-o')
                    hold on
                    if ~isnan(voltmfbpag(i,1))
        %                 plot((find(voltage==voltmfbpag(i,2))-1)/2,y(find(voltage==voltmfbpag(i,2))),'-s','MarkerSize',10,...
        %                     'MarkerEdgeColor','red',...
        %                     'MarkerFaceColor',[1 .6 .6])
                        xline((find(voltage==voltmfbpag(i,2))-1)/2, ...
                            'Color','r','LineWidth',2);
                        hold on
                    end

                    ylim([0 42]);
                    xlim([0 8.5]);
                    title(['Mouse ' mouse{i} ': Self-stimulation during dual stimultion (MFB+PAG)'])
                    xlabel('PAG voltage') 
                    ylabel('Nbr of self-stimulation')
                    makepretty_erc
        end
        print([dirout '/fig_mfbdualcalib_' mouse{i}], '-dpng', '-r300');
        if ismac
            disp('Saving to mac');
        elseif isunix
            system(['sudo chown -R mobs ' dirout]);
        end
    end

end

%--------------------------------------------------------------------------
%                            M F B
%--------------------------------------------------------------------------
% MFB
supertit = ['Self-stimulation during MFB calibration'];
figure2(1,'Color',[1 1 1], 'rend','painters', ...
    'pos',[10 10 1400 800],'Name', supertit, 'NumberTitle','off');
    
    subplot(2,20,1:11)
        for i=1:length(mouse)
            if ok_mfb(i)
                y = mfbnbr(i,:); %nbr stim
                x = voltage(:); %voltage
                idx = ~any(isnan(y),1);

                plot(x(idx),y(idx),'-o','color',randomColors(i,:))
                hold on
                if isnan(y(find(voltage==voltmfbpag(i,1))))
                    % this part interpolate y value if there was no trial
                    % at the chosen voltage. 
                    for j=find(voltage==voltmfbpag(i,1))-1:-1:1
                        if ~isnan(y(j))
                            prev=[j mfbnbr(i,j)];
                            break
                        end
                    end
                    for j=find(voltage==voltmfbpag(i,1))+1:length(voltage)
                        if ~isnan(y(j))
                            nex=[j mfbnbr(i,j)];
                            break
                        end
                    end
                    yy = interp1([prev(1,1) nex(1,1)], [prev(1,2) nex(1,2)], find(voltage==voltmfbpag(i,1)), 'linear', 'extrap');
                    mrk{i} = plot((find(voltage==voltmfbpag(i,1))-1)/2,yy, ...
                        '-o','MarkerSize',14,...
                        'color',randomColors(i,:));
                else
                    % if data exist (default)
                    mrk{i} = plot((find(voltage==voltmfbpag(i,1))-1)/2,y(find(voltage==voltmfbpag(i,1))), ...
                        '-o','MarkerSize',14,...
                        'color',randomColors(i,:));
                end
            end
        end
        hold off
        ylim([0 43]);
        xlim([0 8.5]);
        title('MFB')
        xlabel('MFB voltage') 
        ylabel('Nbr of self-stimulation')
        if exist('mrk','var')
            for i=1:length(mrk)
                if ~isempty(mrk{i})
                    mrk{i}.Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            end
            legend(mouse{find(ok_mfb)}, 'Location','westoutside')
        end
        makepretty_erc

%Normalized MFB
    subplot(2,20,24:31)
    for i=1:length(mouse)
        if ok_mfb(i)
            y = mfbnbr(i,:); %nbr stim
            x = norm_volt(i,:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o','LineWidth',.5,'color',randomColors(i,:))
            hold on
%                 if isnan(y(find(voltage==voltmfbpag(i,2))))
                    % this part interpolate y value if there was no trial
                    % at the chosen voltage. 
                    for j=find(voltage==voltmfbpag(i,2))-1:-1:1
                        if ~isnan(y(j))
                            prev=[j dualnbr(i,j)];
                            break
                        end
                    end
                    for j=find(voltage==voltmfbpag(i,2))+1:length(voltage)
                        if ~isnan(y(j))
                            nex=[j mfbnbr(i,j)];
                            break
                        end
                    end
%                     yy = interp1([prev(1,1) nex(1,1)], [prev(1,2) nex(1,2)], find(voltage==voltmfbpag(i,2)), 'linear', 'extrap');
%                     mrk{i} = plot((find(voltage==voltmfbpag(i,2))-1)/2,yy, ...
%                         '-o','MarkerSize',14,...
%                         'color',randomColors(i,:));
%                 else
%                     % if data exist (default)
%                     mrk{i} = plot((find(voltage==voltmfbpag(i,2))-1)/2,y(find(voltage==voltmfbpag(i,2))), ...
%                         '-o','MarkerSize',14,...
%                         'color',randomColors(i,:));
%                 end
        end
    end
    ylim([0 43]);
%     xlim([0 1]);
    title('Normalized MFB')
    xlabel('Normalized MFB voltage') 
%     ylabel('Nbr of self-stimulation')
%     legend(mouse{find(ok_mfb)}, 'Location','southwestoutside')
    makepretty_erc    

    
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
subplot(2,20,13:20)
    for i=1:length(mouse)
        if ok_dual(i)
            y = dualnbr(i,:); %nbr stim
            x = voltage(:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o','color',randomColors(i,:))
            hold on
            xline(voltmfbpag(i,2),'Color',randomColors(i,:))
        end
    end
    ylim([0 43]);
    xlim([0 8.5]);
    
    title('DUAL (MFB+PAG)')
    xlabel('PAG voltage') 
    ylabel('Nbr of self-stimulation')
%     legend(legtxt,'Location','northeast')
    makepretty_erc
    
% %Normalized Dual
subplot(2,20,33:40)
    for i=1:length(mouse)
        if ok_dual(i)
            y = dualnbr(i,:); %nbr stim
            x = norm_dvolt(i,:); %voltage
            idx = ~any(isnan(y),1);

            plot(x(idx),y(idx),'-o','color',randomColors(i,:))
            hold on
        end
    end
    ylim([0 43]);
%     xlim([0 1]);
    title('Normalized DUAL')
    xlabel('Normalized PAG voltage') 
%     ylabel('Nbr of self-stimulation')
%     legend(legtxt,'Location','northeast')
    makepretty_erc
   
print([dirout '/global_mfbpag_calibration'], '-dpng', '-r300');  
    if ismac
        disp('Saving to mac');
    elseif isunix
        system(['sudo chown -R mobs ' dirout]);
    end    