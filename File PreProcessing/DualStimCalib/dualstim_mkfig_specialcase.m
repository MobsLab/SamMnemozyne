dualnbr = [];

%----------- SAVING PARAMETERS ----------
% Outputs
    dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/WakeStimMFB/';
    if ~exist(dirout, 'dir')
        mkdir(dirout);
    end
    sav=1;      % Do you want to save a figure? Y=1; N=0


%----------- DATA ----------
voltage = [0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.8 9 9.5 10];

mouse = {'M0913'};

voltmfbpag = [3.5 4.5];

%dualnbr = [8 NaN 23 NaN 29 NaN 23 NaN 28 NaN 13 9 2 3 NaN 2 NaN NaN NaN NaN NaN;...
%                29 29 31 23 15 1 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];

dualnbr(1,:,:) = [0 31; 1 21; 2 29; 3 23; 4 24; ...
                  5 29; 6 26; 7 28; 8 24; 8.5 27; ... 
                  9 27; 9.5 25; 9.75 29; 10 26; 10 24]; 
              
% decreasing MFB              
pagnbr(1,:,:) = [4 25; 3.5 26; 3 25; 2.5 22; ...
                2 20; 1.5 19; 1 21; .5 21; 0 18; ...
                0 21; 0 22; 0 20; 0 21];

                
figure
subplot(2,1,1)
    for i=1:length(mouse)
        y = dualnbr(i,:,2); %nbr stim
        x = dualnbr(i,:,1); %voltage

        plot(x,y,'-o')
        hold on
    end
    ylim([0 max(max(dualnbr(:,:,2)))+1]);
    xlim([0 max(max(dualnbr(:,:,1)))+1]);
    title('INCREASING PAG')
    line([4.5; 4.5], [0; 40], 'YLimInclude', 'off', 'color','r','LineStyle','--');
    text(4.5, 4.5, 'Experimental PAG thresh.', ...
     'VerticalAlignment', 'top', 'fontsize',5,'color','r','rotation',90)
    box off
    xlabel('PAG voltage') 
    ylabel('Nbr of self-stimulation')
    legend({['MFB: ' num2str(voltmfbpag(1)) 'V']}, ...
            'Location','southeast')
 
 subplot(2,1,2)
    for i=1:length(mouse)
        y = pagnbr(i,:,2); %nbr stim
        x = pagnbr(i,:,1); %voltage

        plot(x,y,'-o')
        hold on
    end
    
    ylim([0 max(max(dualnbr(:,:,2)))+1]);
    xlim([-.2 4]);
    set ( gca, 'xdir', 'reverse' );
    box off
    title('DECREASING MFB')
    xlabel('MFB voltage') 
    ylabel('Nbr of self-stimulation')
    legend({[ 'PAG: ' num2str(voltmfbpag(2)) 'V']}, ...
            'Location','northeast')
        
        
print([dirout '/fig_dualcalib_M913'], '-dpng', '-r300');