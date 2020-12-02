function [pval,hb,eb] = PlotErrorBarN_SL(A,varargin)

% function pval= PlotErrorBarN_SL(A,varargin)
%
% Modified from PlotErrorBarN_KJ on 05.11.2018 (added handle of bar)
% Modified from PlotErrorBarN_DB on 12.10.2018 (added diff color points per entry)
% 
% 
% INPUT:
% - A                       can be a matrix, line corresponds to dots & columns to bars
%                           or a cell Array
%
% - newfig (optional)       = 1 to display in a new figure, 0 to add on existing 
%                           one (default 1)
% - paired (optional)       = 1 if each line are paired data from a unique mouse, 
%                           0 if from independent groups (default 1, -> signrank test)
% - optiontest (optional)   = 'ttest' , 'ranksum' (default ranksum)
% - norm (optional)          = (default 1), when ttest is chosen, set if
%                               normality is taken into account
% - Horizontal (optional)   = (default 0), to display an horizontal bar plot
% - barcolors (optional)    = (default []), to change the colors of the bars
% - barwidth (optional)     = (default []), to change the width of the bars     
% - showPoints (optional)   = (default 1), 0 to not display individual points 
% - colorPoints (optional)  = (default 0), 1 to have different color per
%                               entry
% - ColumnTest (optional)   = (default 'all pair of columns') pair of columns on which to do statistical tests
% - NonColumnTest (optional)= (default []) pair of columns on which NOT to do statistical tests
% - ShowSigstar (optional)  = (default 'sig') 'none' for no stat
%                             'ns' for only non significant, 'sig' for only
%                             significant, 'all' for all stat
% - y_lim (optional)        = (default None), impose ylim to the grap
%
%
% OUTPUT:
% - p  = p value from ranksum (default) or ttest
% - eb = errorbar handle  
% - hb = bar handle
%
%       see PlotErrorBarN_KJ PlotErrorLineN_KJ PlotErrorSpreadN_KJ
%


%% CHECK INPUTS

if nargin < 1 || mod(length(varargin),2) ~= 0
  error('Incorrect number of parameters.');
end

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'newfig'
            newfig = varargin{i+1};
            if newfig~=0 && newfig ~=1
                error('Incorrect value for property ''newfig''.');
            end
        case 'paired'
            paired = varargin{i+1};
            if paired~=0 && paired ~=1
                error('Incorrect value for property ''paired''.');
            end
        case 'optiontest'
            optiontest = varargin{i+1};
            if ~isstring_FMAToolbox(optiontest, 'ttest' , 'ranksum')
                error('Incorrect value for property ''optiontest''.');
            end
        case 'norm'
            norm = varargin{i+1};
            if norm~=0 && norm ~=1
                error('Incorrect value for property ''norm''.');
            end
        case 'horizontal'
            horizontal = varargin{i+1};
            if horizontal~=0 && horizontal ~=1
                error('Incorrect value for property ''Horizontal''.');
            end
        case 'showpoints'
            showpoints = varargin{i+1};
            if showpoints~=0 && showpoints ~=1
                error('Incorrect value for property ''showPoints''.');
            end
        case 'colorpoints'
            colorpoints = varargin{i+1};
            if colorpoints~=0 && colorpoints ~=1
                error('Incorrect value for property ''colorPoints''.');
            end    
        case 'barcolors'
            barcolors = varargin{i+1};
        case 'barwidth'
            barwidth = varargin{i+1};
            if ~isvector(barwidth) || length(barwidth)~=1
                error('Incorrect value for property ''barwidth''.');
            end
        case 'columntest'
            column_test = varargin{i+1};
            if size(column_test,2)~=2
                error('Incorrect value for property ''ColumnTest''.');
            end
        case 'noncolumntest'
            noncolumn_test = varargin{i+1};
            if size(noncolumn_test,2)~=2
                error('Incorrect value for property ''NonColumnTest''.');
            end
        case 'showsigstar'
            ShowSigstar = varargin{i+1};
            if ~isstring_FMAToolbox(ShowSigstar, 'none' , 'ns', 'sig', 'all')
                error('Incorrect value for property ''ShowSigstar''.');
            end
        case 'y_lim'
            y_lim = varargin{i+1};
            if ~isvector(y_lim) || length(y_lim)~=2
                error('Incorrect value for property ''y_lim''.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
if ~exist('newfig','var')
    newfig=1;
end
if ~exist('paired','var')
    paired=1;
end
if ~exist('optiontest','var')
    optiontest='ranksum';
end
if ~exist('norm','var')
    norm=1;
end
if ~exist('horizontal','var')
    horizontal=0;
end
if ~exist('showpoints','var')
    showpoints=1;
end
if ~exist('colorpoints','var')
    colorpoints=0;
elseif colorpoints && ~showpoints
    showpoints=1;  % by default showpoints must be ON to color the points
end
if ~exist('barcolors','var')
    barcolors=[];
end
if ~exist('barwidth','var')
    barwidth=[];
end
if ~exist('ShowSigstar','var')
    ShowSigstar='sig';
end

%------------- FIGURE PARAMETERS -------------
% define colors
clrs_default = get(gca,'colororder');
color_extra = [65	16	16; 
                87	72	53;	
                37	62	63;	
                50	100	0;
                82	41	12;	
                100	50	31;	
                39	58	93;	
                100	97	86;	
                86	8	24;	
                0	100	100;
                0	0	55;
                0	55	55;	
                72	53	4;
                66	66	66;	
                0 39 0]/100;
clrs_default = [clrs_default; color_extra];


%eventually formating A to cell
if ~iscell(A)
    tempA=A; A={};
    for i=1:size(tempA,2)
        A{i}=tempA(:,i);
    end
end

%default column that are tested statistically
if ~strcmpi(ShowSigstar,'none')
    if ~exist('column_test','var')
        column_test = nchoosek(1:length(A),2);
    end 
    if exist('noncolumn_test','var')
        [~,indx] = ismember(noncolumn_test, column_test,'rows');
        column_test(indx,:) = [];
    end
    column_test = mat2cell(column_test,ones(1,size(column_test,1)),2);
else
    column_test = cell(0);
end

if strcmpi(ShowSigstar,'sig')
    ShowNS = 0;
    ShowSig = 1;
elseif strcmpi(ShowSigstar,'ns')
    ShowNS = 1;
    ShowSig = 0;
elseif strcmpi(ShowSigstar,'all')
    ShowNS = 1;
    ShowSig = 1;
end


%% GET DATA FROM A

N=length(A); %number of column
R=[];
E=[];
S=[];

for i=1:N
    if ~isempty(A{i})
        [Ri,Si,Ei]=MeanDifNan(A{i});
        R=[R,Ri];
        S=[S,Si];
        E=[E,Ei];
    else
        R=[R,nan];
        S=[S,nan];
        E=[E,nan];
    end
end


%% DISPLAY

%insert graph in an existing figure or create a new one
if newfig
    figure('color',[1 1 1]),
end
figure(gcf), hold on,


%% BAR PLOT

%
bar_argin = {'EdgeColor','k'};
if ~isempty(barwidth)
    bar_argin{end+1} = 'BarWidth'; 
    bar_argin{end+1} = barwidth;
end

%classic, vertical
if ~horizontal
    %bar colors
    if isempty(barcolors)
        hb = bar(R,'FaceColor',[0.3 0.3 0.3],bar_argin{:});
    elseif ~iscell(barcolors)
        hb = bar(R,'FaceColor',barcolors,bar_argin{:});
    elseif length(barcolors)==1
            hb = bar(R,'FaceColor',barcolors{1},bar_argin{:});
    else
        for i=1:length(R)
            hb = bar(i, R(i), 'FaceColor', barcolors{i},bar_argin{:});
        end
    end

    %plot the bars with the errors
    eb = errorbar([1:length(E)],R,zeros(1,length(E)),E,'+','Color','k');
    xlim([0 N+1])
    if exist('y_lim','var')
        ylim(y_lim)
    end

%horizontal
else
    %bar colors
    if isempty(barcolors)
        barh(R,'FaceColor',[0.3 0.3 0.3],'EdgeColor','k')
    elseif length(barcolors)==1
        barh(R,'FaceColor',barcolors{1},'EdgeColor','k')
    else
        for i=1:length(R)
            barh(i, R(i), 'FaceColor', barcolors{i},'EdgeColor','k');
        end
    end
    
    %plot the bars with the errors
    eb = errorbar(R,1:length(E),E,zeros(1,length(E)),'.k');
    
    ylim([0 N+1])
    if exist('y_lim','var')
        xlim(y_lim)
    end
end

% if showPoints is equal to 1
if showpoints && ~horizontal
    
    %plot points, indicating value for each individual
    for i=1:N
        temp=A{i}(~isnan(A{i}));
        if colorpoints
            for itemp=1:length(temp)
                plot(i*ones(1,1)+0.1,temp(itemp),'ko','markerfacecolor',clrs_default(itemp,1:3))
            end
        else
            plot(i*ones(length(temp),1)+0.1,temp,'ko','markerfacecolor','w')
        end
    end

    %if paired data, data are linked together, for each individual, with line
    if paired
        M = cell2mat(A);
        if size(M,1)==1
            M=cell2mat(A')';
        end
        
        nb_individual=size(M,1); %number of indivudual
        for k=1:nb_individual
            idx = find(~isnan(M(k,:)));
            for i=1:length(idx)-1
                try 
                    line(0.1+[idx(i) idx(i+1)]', [M(k,idx(i)) M(k,idx(i+1))]', 'color',[0.6 0.6 0.6]); 
                end
            end
        end
    end
end

%% STATISTICAL TESTS

thresh_signif=0.05;  % stat param: threshold for statistical significance

if ~isempty(column_test)
    
    % Rank sum Wilcoxon
    if strcmp(optiontest,'ranksum')
        pval=nan(N,N);
        groups = cell(0);
        stats = [];
        for c=1:length(column_test)
            i = column_test{c}(1);
            j = column_test{c}(2);
            if sum(~isnan(A{i}))>2 && sum(~isnan(A{j}))>2
                if paired
                    idx=find(~isnan(A{i}) & ~isnan(A{j}));
                    [p,h]= signrank(A{i}(idx),A{j}(idx));
                else
                    [p,h]=ranksum(A{i}(~isnan(A{i})),A{j}(~isnan(A{j})));
                end
                pval(i,j)=p; pval(j,i)=p;
                if h==1 && ShowSig==1
                    groups{length(groups)+1}=[i j];
                    stats = [stats p];
                elseif h==0 && ShowNS==1
                    groups{length(groups)+1}=[i j];
                    stats = [stats p];
                end
           end
        end
        stats(stats>thresh_signif)=nan;
        if ~horizontal
            sigstar_DB(groups,stats,0,'LineWigth',16,'StarSize',24);
        else
            sigstarh(groups,stats)
        end
    % T-test
    elseif strcmp(optiontest,'ttest')
        pval=nan(N,N);
        groups = cell(0);
        stats = [];
        % normality
        for i=1:N
            [hi,~,~]=swtest(A{i},0.05);
            hnorm(i)=hi;
        end
        % normal distributions with same variance
        for i=1:N
            for j=i:N
                [hi,~,~]=vartest2(A{i},A{j});
                hvar(i,j)=hi;
            end
        end
        % test
        for c=1:length(column_test)
            i = column_test{c}(1);
            j = column_test{c}(2);
            if norm 
                if hnorm(i)+hnorm(j)==0 && hvar(min(i,j),max(i,j))==0
                    [h,p]=ttest2(A{i},A{j});
                    pval(i,j)=p; pval(j,i)=p;
                    if h==1 && ShowSig==1
                        groups{length(groups)+1}=[i j];
                        stats = [stats p];
                    elseif h==0 && ShowNS==1
                        groups{length(groups)+1}=[i j];
                        stats = [stats p];
                    end
                end
            else
                [h,p]=ttest2(A{i},A{j});
                pval(i,j)=p; pval(j,i)=p;
                if h==1 && ShowSig==1
                    groups{length(groups)+1}=[i j];
                    stats = [stats p];
                elseif h==0 && ShowNS==1
                    groups{length(groups)+1}=[i j];
                    stats = [stats p];
                end
            end        
        end
        stats(stats>thresh_signif)=nan;
        if ~horizontal
            sigstar_DB(groups,stats,0,'LineWigth',16,'StarSize',24);
        else
            sigstarh(groups,stats)
        end
    end
end

%% TERMINATION
if ~exist('pval','var')
    pval=nan;
end

end


