%----------- VARIABLE TO SET ----------
%set mice ID
mouse = {'M1039','M1199'};
 
% with electrophy
ok_mfb =  [0 1]; % mouse that are use in experiment
ok_dual = [0 1]; % mouse that are use in experiment
%set MFB voltage used during dual
voltmfbpag = [3 5; 3.5 6];
          
%----------- SAVING PARAMETERS ----------
% Outputs
dirout = [dropbox 'DataSL/Calibration/Multipass/' date '/'];
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

% M1039
mfbnbr{1,1} = [0 4; 1 13; 2 23; 3 29; 3.5 37; 4 36; 4.5 39; 5 40; 5.5 42; 6 41];
mfbnbr{1,2} = [6 41; 4 43; 3.5 40; 3 40; 2.5 43; 2 35; 1.5 23; 1 2; 0 8];
mfbnbr{1,3} = [0 8; 1 9; 2 43; 2.5 46; 3 46; 4 39];
mfbnbr{1,4} = [4 39; 3.5 49; 3 45; 2.5 47; 2 41; 1 2];
% M1199
mfbnbr{2,1} = [0 5; 1 8; 2 5; 3 3; 4 30; 4.5 37; 5 35];
mfbnbr{2,2} = [5 35; 4.5 36; 4 32; 3.5 34; 3 34; 2.5 15; 2 11];
mfbnbr{2,3} = [2 11; 2.5 25; 3 35; 3.5 35; 4 38; 4.5 41];
mfbnbr{2,4} = [4.5 41; 4 34; 3.5 32; 3 31; 2.5 24; 2 21; 1 17];

% get colors for plot
clrs = parula(size(mfbnbr,2)+2);

%--------------------------------------------------------------------------
%                            M F B
%--------------------------------------------------------------------------
% MFB
for i=1:length(mouse)
    if ok_mfb(i)
        supertit = [mouse{i} ': Self-stimulation during MFB calibration'];
        figure2(1,'Color',[1 1 1], 'rend','painters', ...
            'pos',[10 10 600 400],'Name', supertit, 'NumberTitle','off');
                    for ipass=1:2:size(mfbnbr,2)
                        plot(mfbnbr{i,ipass}(:,1),mfbnbr{i,ipass}(:,2),'-o','color',clrs(ipass,:))
                        hold on
                        plot(mfbnbr{i,ipass+1}(:,1),mfbnbr{i,ipass+1}(:,2),'--o','color',clrs(ipass,:))
                        hold on
                    end
                    hold off
                    xline(voltmfbpag(i,1));
                hold off
                ylim([0 50]);
                xlim([0 7]);
                title([mouse{i} ': MFB'])
                xlabel('MFB voltage') 
                ylabel('Nbr of self-stimulation')
                legend({'Pass 1: Increasing','Pass 1: Decreasing', ...
                        'Pass 2: Increasing','Pass 2: Decreasing'}, ...
                        'Location','southeast')
                makepretty_erc

        % %Normalized MFB
        %     subplot(2,20,24:31)
        %     for i=1:length(mouse)
        %         if ok_mfb(i)
        %             y = mfbnbr(i,:); %nbr stim
        %             x = norm_volt(i,:); %voltage
        %             idx = ~any(isnan(y),1);
        % 
        %             plot(x(idx),y(idx),'-o','LineWidth',.5,'color',randomColors(i,:))
        %             hold on
        %         end
        %     end
        %     ylim([0 43]);
        % %     xlim([0 1]);
        %     title('Normalized MFB')
        %     xlabel('Normalized MFB voltage') 
        % %     ylabel('Nbr of self-stimulation')
        % %     legend(mouse{find(ok_mfb)}, 'Location','southwestoutside')
        %     makepretty_erc    


        print([dirout '/' mouse{i} '_mfb_calibration'], '-dpng', '-r300');  
        if ismac
            disp('Saving to mac');
        elseif isunix
            system(['sudo chown -R mobs ' dirout]);
        end
    end
end