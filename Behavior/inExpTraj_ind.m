function fgh = inExpTraj_ind(ntest)
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

sizeMapx=240;         %Map size
sizeMapy=320;         %Map size

supertit = ['Trajectories & occupancy'];
fgh = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2000 550],'Name', supertit, 'NumberTitle','off');
for i=1:ntest
    subplot(2,ntest,i)
            load(['behavResources' num2str(i) '.mat'],'AlignedXtsd','AlignedYtsd','ZoneEpoch','PosMat');
            x = Data(AlignedXtsd);
            y = Data(AlignedYtsd);
            dur = PosMat(end,1)-PosMat(1,1);
            ztime(1,i) = (sum(End(ZoneEpoch{1})-Start(ZoneEpoch{1}))/1E4)/dur*100; 
            ztime(2,i) = (sum(End(ZoneEpoch{2})-Start(ZoneEpoch{2}))/1E4)/dur*100; 

            clear Xtsd Ytsd ZoneEpoch PosMat

            %plot traj
            plot(x,y)
            % constructing the u maze
            line([0 0],[0 1.05],'Color','black','LineWidth',2) % left outside arm
            line([1 1],[0 1.05],'Color','black','LineWidth',2) % right outside arm
            line([0 .375],[0 0],'Color','black','LineWidth',2) % bottom left outside
            line([.625 1],[0 0],'Color','black','LineWidth',2) % bottom right outside
            line([.375 .375],[0 .75],'Color','black','LineWidth',2) % left inside arm
            line([.625 .625],[0 .75],'Color','black','LineWidth',2) % right inside arm
            line([.375 .625],[.75 .75],'Color','black','LineWidth',2) % center inside arm
            line([0 1],[1.05 1.05],'Color','black','LineWidth',2) % up outside
            % stim zone
            line([-.01 -.01],[-.01 .385],'Color','green','LineWidth',1.5) % left stim
            line([.376 .376],[-.01 .385],'Color','green','LineWidth',1.5) % right stim
            line([-.01 .385],[-.01 -.01],'Color','green','LineWidth',1.5) % top stim
            line([-.01 .385],[.385 .385],'Color','green','LineWidth',1.5) % bottom stim  
            
        title(['trial: ' num2str(i)])    
        set(gca,'visible','off')
%         makepretty_erc('fsizel',16,'lwidth',2,'fsizet',16)

    % plot occup
    subplot(2,ntest,i+ntest)
       [p,h,her] = PlotErrorBarN_SL([ztime(1,i)' ztime(2,i)'],...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        set(gca,'xticklabel',{'','Stim','No-S',''})
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('%');       
        hline(20,'--k')
        ylim([0 90])
        makepretty_erc('fsizel',12,'lwidth',2,'fsizet',16)
end

Name = ['Trajectories_occupancy'];
print([pwd '/' Name],'-dpng','-r300')

