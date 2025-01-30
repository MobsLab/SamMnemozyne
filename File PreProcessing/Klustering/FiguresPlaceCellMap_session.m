function FiguresPlaceCellMap_session(session, varargin)

%==========================================================================
% Details: Output firing location in space
%
% INPUTS:
%       - session:  session name to be mapped (string in cell:
%                   {'Hab1','Hab2'}). If only one session, it still must be
%                   between curly brackets (as cell). 
%
%       - varargin:
%               - pooled: set to 0 default. Set to 1 to pool the sessions
%               into one.
%               - save_data: saving data = 1 (default)
%               - recompute spikes (if changes were made to clu files):
%               default = 1
%
% OUTPUT:
%       - figures including:
%           - Trajectories with firing locations
%           - Firing maps (real and poisson dist)
%
% NOTES:
%
%   Written by Samuel Laventure - 18-04-2019
%   Modified by SL - 27/02/2020 - added pooling options, save_data, changed
%       global maps figure display
%      
%==========================================================================

%% Initiation

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'pooled'
            pooled = varargin{i+1};
        case 'save_data'
            save_data = varargin{i+1};
        case 'recompute'
            recompute = varargin{i+1};
        case 'plotfig'
            plotfig = varargin{i+1};
        case 'unique'
            unique = varargin{i+1};
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end
warning('off','all')
%check if exist and assign default value if not
% pooling session
if ~exist('pooled','var')
    pooled = 0;
end
%save_data?
if ~exist('save_data','var')
    save_data = 1;
end
%recompute?
if ~exist('recompute','var')
    recompute = 1;
end
%plot figures?
if ~exist('plotfig','var')
    plotfig = 0;
end
%unique
if ~exist('unique','var')
    unique = 0;
end


%INIT VAR
nsess=length(session);

%saving all trajectories maps parameters
dirPath = [pwd '/PlaceCells/' cell2mat(session) '_' date '/' ];
figName = 'All_traj';
sformat = 'dpng';
res = 300;
% create directory if doesn't exist and set permissions
if ~exist(dirPath, 'dir')
    mkdir(dirPath);
end
% special case for Matlab on Linux using in root 
if isunix
    system(['sudo chown -R hobbes /' pwd]);
end
    
%% MAIN SCRIPT
load('behavResources.mat');
if ~unique
    fSess = fieldnames(SessionEpoch);  %get structure field names 
    %Verify that all session called exist
    for isess=1:nsess
        id_allsess = strfind(fSess,session{isess});
        idx = strcmp(fSess,session{isess});
        id_sess(isess)=find(idx==1);
        ansfind = find(not(cellfun('isempty',id_allsess)));
        if ~ansfind
            error(['The session ' session{isess} 'does not exist.']);
        end
    end
else
    sessEpoch = intervalSet(1,PosMat(end,1)*1e4);
end

SetCurrentSession('same');
MakeData_Spikes('mua',1,'recompute',recompute);

load('SpikeData.mat');

LocomotionEpoch = thresholdIntervals(Vtsd,5,'Direction', 'Above');
hist(Data(Vtsd), 100)

if ~unique
    try ~isnan(sum(Data(AlignedXtsd)))
        if ~isnan(sum(Data(AlignedXtsd)))
            XS = Restrict(AlignedXtsd,LocomotionEpoch);
            YS = Restrict(AlignedYtsd,LocomotionEpoch);
        else
            XS = Restrict(Xtsd,LocomotionEpoch);
            YS = Restrict(Ytsd,LocomotionEpoch);
        end
    catch
        XS = Restrict(Xtsd,LocomotionEpoch);
        YS = Restrict(Ytsd,LocomotionEpoch);
    end
else 
    XS = Restrict(Xtsd,LocomotionEpoch);
    YS = Restrict(Ytsd,LocomotionEpoch);
end

%set number of clu by tetrode
cluarr = cell2mat(TT);
for itet=1:length(tetrodeChannels)
    if length(find(cluarr(1:2:end)==itet))
        clunum(itet) = length(find(cluarr(1:2:end)==itet));
    else
        clunum(itet) = 0;
    end
end

% Pooling sessions
if pooled % pooled sessions
    % pooling
    for isess=1:nsess
        if isess==1
            SessPool = SessionEpoch.(fSess{id_sess(isess)}); %initialize ts    
        else
            SessPool = or(SessPool,SessionEpoch.(fSess{id_sess(isess)}));
        end
    end
    % create maps
    for i=1:length(S) 
        try
            [map{i}, mapNS, stats{i}, px{i}, py{i}, FR{i}, xB, yB] = ... 
                PlaceField_DB(Restrict(Restrict(S{i},LocomotionEpoch),SessPool), ...
                Restrict(XS,SessPool), Restrict(YS,SessPool), ... 
                'smoothing',1.5, 'size', 50,'plotresults',0,'plotpoisson',plotfig);
            hold on
            mtit(cellnames{i}, 'fontsize',14, 'xoff', -.6, 'yoff', 0) %set global title for each figure (tetrode and cluster #)        catch
            disp(['No map available for ' cellnames{i}]);
        end
    end
%     % create global maps
%     if exist('map','var')
%         iclu=1;
%         for t=1:size(tetrodeChannels,2)
%             if clunum(t)
%                 figure('Color',[1 1 1], 'rend','painters','pos',[10 10 300*clunum(t) 400])
%                     for i=1:clunum(t)
%                         subplot(1,clunum(t),i)
%                             if ~isempty(map{iclu})    
%                                 imagesc(map{1,iclu}.rate)
%                                 title(cellnames{iclu})
%                             end
%                         iclu=iclu+1;
%                     end
%                     if save_data
%                         print([pwd '/PlaceCells/' cell2mat(session) '/SpikeGroup' num2str(t) ], '-dpng', '-r300');
%                     end
%             end
%         end
%     end
    
    supertit='All clusters from all tet/probes';
    H = figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 1800 1200],'Name', supertit, 'NumberTitle','off');
    for i=1:length(S) 
        if ~isempty(map{i})
            si = round(stats{i}.spatialInfo,2);
            fr = round(FR{i},2);
            subplot(5,ceil(length(S)/5),i)
                plot(Data(Restrict(XS,SessPool)),Data(Restrict(YS,SessPool)),'Color',[0.8 0.8 0.8])
                hold on, plot(px{i},py{i},'r.')
                [xl, yl] = DefineGoodFigLimits_2D(Data(Restrict(XS,SessPool)),Data(Restrict(YS,SessPool)));
                xlim(xl); ylim(yl);
                set(gca,'xticklabel',{[]})
                set(gca,'yticklabel',{[]})
                title([cellnames{i} ', SI:' num2str(si) ', FR:' num2str(fr)],'FontSize',6);
        end
    end
    
    % saving
    set(H,'paperPositionMode','auto')
    for i=1:length(sformat)
        print(H,[dirPath figName], ['-' sformat], ['-r' num2str(res)]);
    end
    % saving in .fig format 
    saveas(H,[dirPath figName],'fig');

    % special case for Matlab on Linux using in root 
    if isunix
        system(['sudo chown -R hobbes /' dirPath]);
    end
    
else  % individual sessions
    if ~unique
        for isess=1:nsess
            if ~exist([pwd '/PlaceCells/' session{isess}],'dir')
                mkdir([pwd '/PlaceCells/' session{isess}]);
            end
            for i=1:length(S) 
                try
                    [map{i}, mapNS, stats{i}, px{i}, py{i}, FR{i}, xB, yB] = ... 
                    PlaceField_DB(Restrict(Restrict(S{i},LocomotionEpoch),SessionEpoch.(fSess{id_sess(isess)})), ...
                        Restrict(XS,SessionEpoch.(fSess{id_sess(isess)})), ... 
                        Restrict(YS,SessionEpoch.(fSess{id_sess(isess)})), ... 
                        'smoothing',1.5, 'size', 50,'plotresults',0,'plotpoisson',plotfig);
                    hold on
                    mtit(cellnames{i}, 'fontsize',14, 'xoff', -.6, 'yoff', 0) %set global title for each figure (tetrode and cluster #)
                    if save_data
                        print([pwd '/PlaceCells/' session{isess} '/' cellnames{i} ], '-dpng', '-r300'); %
                    end
                catch
                    map{i} = [];
                    disp(['No map available for ' cellnames{i}]);
                end
            end
            % Figure
            supertit='All clusters from all tet/probes';
            H = figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 1800 1200],'Name', supertit, 'NumberTitle','off');
            for i=1:length(S) 
                if ~isempty(map{i})
                    si = round(stats{i}.spatialInfo,2);
                    fr = round(FR{i},2);
                    subplot(5,ceil(length(S)/5),i)
                        plot(Data(XS),Data(YS),'Color',[0.8 0.8 0.8])
                        hold on, plot(px{i},py{i},'r.')
                        [xl, yl] = DefineGoodFigLimits_2D(Data(XS),Data(YS));
                        xlim(xl); ylim(yl);
                        set(gca,'xticklabel',{[]})
                        set(gca,'yticklabel',{[]})
                        title([cellnames{i} ', SI:' num2str(si) ', FR:' num2str(fr)],'FontSize',6);
                end
            end

            % saving
            set(H,'paperPositionMode','auto')
            for i=1:length(sformat)
                print(H,[dirPath figName], ['-' sformat], ['-r' num2str(res)]);
            end
            % saving in .fig format 
            saveas(H,[dirPath figName],'fig');

            % special case for Matlab on Linux using in root 
            if isunix
                system(['sudo chown -R hobbes /' dirPath]);
            end
        end
    else
        if ~exist([pwd '/PlaceCells/' session{1}],'dir')
            mkdir([pwd '/PlaceCells/' session{1}]);
        end
        for i=1:length(S) 
            try
                [map{i}, mapNS, stats{i}, px{i}, py{i}, FR{i}, xB, yB] = ... 
                PlaceField_DB(Restrict(S{i},LocomotionEpoch),XS,YS, ... 
                    'smoothing',1.5, 'size', 50,'plotresults',0,'plotpoisson',plotfig);
                hold on
                mtit(cellnames{i}, 'fontsize',14, 'xoff', -.6, 'yoff', 0) %set global title for each figure (tetrode and cluster #)
                if save_data
                    print([pwd '/PlaceCells/' session{1} '/' cellnames{i} ], '-dpng', '-r300'); %
                end
            catch
                map{i} = [];
                disp(['No map available for ' cellnames{i}]);
            end
        end

        supertit='All clusters from all tet/probes';
        H = figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 1800 1200],'Name', supertit, 'NumberTitle','off');
        for i=1:length(S) 
            if ~isempty(map{i})
                si = round(stats{i}.spatialInfo,2);
                fr = round(FR{i},2);
                subplot(5,ceil(length(S)/5),i)
                    plot(Data(XS),Data(YS),'Color',[0.8 0.8 0.8])
                    hold on, plot(px{i},py{i},'r.')
                    [xl, yl] = DefineGoodFigLimits_2D(Data(XS),Data(YS));
                    xlim(xl); ylim(yl);
                    set(gca,'xticklabel',{[]})
                    set(gca,'yticklabel',{[]})
                    title([cellnames{i} ', SI:' num2str(si) ', FR:' num2str(fr)],'FontSize',6);
            end
        end

        % saving
        set(H,'paperPositionMode','auto')
        for i=1:length(sformat)
            print(H,[dirPath figName], ['-' sformat], ['-r' num2str(res)]);
        end
        % saving in .fig format 
        saveas(H,[dirPath figName],'fig');

        % special case for Matlab on Linux using in root 
        if isunix
            system(['sudo chown -R hobbes /' dirPath]);
        end
    end
end

end