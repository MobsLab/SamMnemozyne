function fgh = inExpTraj(ntest)
%%
%   Quick function to verify trajectories and occupancy 
%   Need all behavResources in the current folder numbered by suffixe.
%   
%   Input: 
%       ntest       number of behavResources to process
%
%   Output
%       fgh         figure handles
%
%   Ex:   
%               behavResources1
%               behavResources2
%               behavResources3
%
%  Written by SL - 2021-01
%--------------------------------------------------------------------------

supertit = 'Trajectories & occupancy';
fgh = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 500 800],'Name', supertit, 'NumberTitle','off');
    subplot(2,1,1)
        for i=1:ntest
            load(['behavResources' num2str(i) '.mat'],'Xtsd','Ytsd','ZoneEpoch','PosMat');
            x = Data(Xtsd);
            y = Data(Ytsd);
            dur = PosMat(end,1)-PosMat(1,1);
            ztime(1,i) = (sum(End(ZoneEpoch{1})-Start(ZoneEpoch{1}))/1E4)/dur*100; 
            ztime(2,i) = (sum(End(ZoneEpoch{2})-Start(ZoneEpoch{2}))/1E4)/dur*100; 

            clear Xtsd Ytsd ZoneEpoch PosMat

            %plot traj
            plot(x,y)
            hold on	
        end
        set(gca,'visible','off')
        makepretty_erc('fsizel',16,'lwidth',2,'fsizet',16)
        
    % plot occup
    subplot(2,1,2)
       [p,h,her] = PlotErrorBarN_SL([ztime(1,:)' ztime(2,:)'],...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        set(gca,'xticklabel',{'','','Stim','','NoStim','',''})
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('%');       
        hline(20,'--k')
        title('Occupancy')
        makepretty_erc('fsizel',16,'lwidth',2,'fsizet',16)
        
Name = ['Trajectories & occupancy'];
title([Name])
print([pwd '/' Name],'-dpng','-r300')


