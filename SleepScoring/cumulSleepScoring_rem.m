function [level level_slp stgperc Onset] = cumulSleepScoring_rem(expe, mice_num, numexpe, restrictlen, plotfig)
% wrapper

% var init
binlen = 10;

% get PathForExp
for i=1:length(expe)
    Dir{i} = PathForExperimentsERC(expe{i});
    switch expe{i}
        case 'StimMFBWake'
            expname{i}='MFB';
        case 'Novel'
            expname{i}='Novel';
        case 'UMazePAG'
            expname{i}='PAG';
        case 'Known'
            expname{i}='Known';
    end
    Dir{i} = RestrictPathForExperiment(Dir{i}, 'nMice', unique(mice_num{i}));
end


% get sleep epoch by stage
disp('Getting data...')
for iexp=1:length(expe)
    disp(['   Experiment: ' expname{iexp}])
    nsuj=0;
    for isuj = 1:length(Dir{iexp}.path)
        for iisuj=1:length(Dir{iexp}.path{isuj})
            nsuj=nsuj+1;
            load([Dir{iexp}.path{isuj}{iisuj} 'behavResources.mat'], 'SessionEpoch','Vtsd'); 
            [sEpoch{iexp,nsuj} subst(iexp,nsuj) sSession{iexp,nsuj}] = get_SleepEpoch(Dir{iexp}.path{isuj}{iisuj},Vtsd);
            path{iexp,nsuj}=Dir{iexp}.path{isuj}{iisuj};
        end
    end
    num_exp(iexp) = nsuj;
end
disp('Done.')
disp('-------------------')
disp('Calculations')

%check session length (optional param)
for iexp=1:length(expe)
    for isuj=1:num_exp(iexp)
        if ~isempty(sEpoch{iexp,isuj}{1,3})
            if restrictlen
                st1=Start(sEpoch{iexp,isuj}{1,7});
                en1=End(sEpoch{iexp,isuj}{1,7});
                tot1=sum(en1-st1)/1e4;
                st2=Start(sEpoch{iexp,isuj}{2,7});
                en2=End(sEpoch{iexp,isuj}{2,7});
                tot2=sum(en2-st2)/1e4;
                if (tot1>restrictlen) && (tot2>restrictlen)
                    ok(iexp,isuj)=1;
                else 
                    ok(iexp,isuj)=0;
                end
                clear st1 st2 en1 en2 tot1 tot2
            else
                ok(iexp,isuj)=1;
            end            
            % exceptions
%             if isuj==6 || isuj==12 % PAG905, PAG1117
%                 ok(iexp,isuj)=0;
%             end
        end
    end
end

level = nan(3,max(num_exp),2,10);
sessname={'Pre-Sleep','Post-Sleep'};

for iexp=1:length(expe)
    disp(['-----' expname{iexp} '-----'])
    num=0;
    for isuj=1:num_exp(iexp)
        disp(['Processing ' num2str(mice_num{iexp}(isuj))])
        if plotfig
            supertit = ['Cumulative sleep percentage by session - ' num2str(mice_num{iexp}(isuj))];
            figH = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1400 500],'Name', supertit, 'NumberTitle','off');
        end
        for isess=1:2
            disp(['    ' sessname{isess}])
            if ~isempty(sEpoch{iexp,isuj}{isess,3}) && ok(iexp,isuj)
                % session, sleep durations
                sess_epoch = or(sEpoch{iexp,isuj}{isess,3},sEpoch{iexp,isuj}{isess,7});
                dur = sum(End(sess_epoch)-Start(sess_epoch))/60e4;
                
                num=num+1;
                % set begining and end 
                lenepoch = Data(length(sEpoch{iexp,isuj}{isess,7}))/1e4;
                lenstage = 0;
                for i=1:length(lenepoch)
                    if sum(lenstage)+lenepoch(i)<restrictlen
                        lenstage=lenstage+lenepoch(i);
                    else
                        if restrictlen
                            stlast = Start(subset(sEpoch{iexp,isuj}{isess,7},i));
                            endrest = stlast + restrictlen*1e4 - lenstage*1e4;
                        else
                            endrest = End(subset(sSession{iexp,isuj}{isess},...
                                length(End(sSession{iexp,isuj}{isess}))));
                        end
                        break
                    end
                end
                st = Start(sSession{iexp,isuj}{isess});
                islen = intervalSet(st,endrest);
                % restrict to min duration and create main epoch variable
                for irest=1:4
                    if irest==4
                        irest=7;
                    end
                    if restrictlen                            
                        epoch{irest} = and(sEpoch{iexp,isuj}{isess,irest},islen);
                    else
                        epoch{irest} = sEpoch{iexp,isuj}{isess,irest};
                    end
                end
                % set session length
                if restrictlen
                    sesslen(iexp,isess,num) = restrictlen/60;
                else
                    sesslen(iexp,isess,num) = dur;
                end
                sessdur(iexp,isess,num) = dur;
                sesssleep(iexp,isess,num) = sum(End(sEpoch{iexp,isuj}{isess,7})-Start(sEpoch{iexp,isuj}{isess,7}))/60e4;
                % get cumul percentage for session
                stgperc{iexp,isuj,isess} = cumulSleepScoring(path{iexp,isuj},binlen,'epoch',islen);
                % plot stage percentage 
                if plotfig
                    if isess==1, pos=1; else pos=3; end
                    subplot(2,4,pos:pos+1)
                        plot(stgperc{iexp,isuj,isess}'), hold on
                            ylabel('(%)')
                            if isess==2
                                legend({'NREM','REM','Wake'})
                            end
                            ylim([0 100])
                            xlim([1 size(stgperc{iexp,isuj,isess},2)])
                            xticks([100:100:size(stgperc{iexp,isuj,isess},2)]);
                            xticklabels({[100*binlen:100*binlen:size(stgperc{iexp,isuj,isess},2)*binlen]})
                            title([num2str(mice_num{iexp}(isuj)) ' - ' sessname{isess}])
                            makepretty_erc
                    subplot(2,4,pos+4:pos+5)
                        plot(stgperc{iexp,isuj,isess}'), hold on
                            ylabel('(%)')
                            ylim([0 20])
                            xlim([1 size(stgperc{iexp,isuj,isess},2)])
                            xticks([100:100:size(stgperc{iexp,isuj,isess},2)]);
                            xticklabels({[100*binlen:100*binlen:size(stgperc{iexp,isuj,isess},2)*binlen]})
                            title([num2str(mice_num{iexp}(isuj)) ' - ' sessname{isess} ' - REM focus'])
                            xlabel('Seconds')
                            makepretty_erc
                end
                % get onsets sleep, rem (from session and sleep)
                Onset.sleep(iexp,isuj,isess) =  ...
                    find(~isnan(stgperc{iexp,isuj,isess}(1,:))>0,1,'first')*binlen;
                Onset.remsess(iexp,isuj,isess)  = ...
                    find(stgperc{iexp,isuj,isess}(2,:)>0,1,'first')*binlen;
                Onset.remsleep(iexp,isuj,isess) = ...
                    find(stgperc{iexp,isuj,isess}(2,:)>0,1,'first')*binlen-Onset.sleep(iexp,isuj,isess);
                % get level reached data
                for iperc=1:10
                    if ~isempty(find(stgperc{iexp,isuj,isess}(2,:)>iperc,1,'first'))
                        level(iexp,isuj,isess,iperc) = ...
                            find(stgperc{iexp,isuj,isess}(2,:)>iperc,1,'first')*binlen;
                        level_slp(iexp,isuj,isess,iperc) = ...
                            (find(stgperc{iexp,isuj,isess}(2,:)>iperc,1,'first')-Onset.sleep(iexp,isuj,isess))*binlen;                        
                    end
                end
            end
            clear islen st endrest stlast lenstage
        end
        
        % save figure
        if plotfig
            figName = ['CumulativeSleepScoring_NoWake_' expname{iexp} '_' ...
                num2str(numexpe{iexp}(isuj)) '_M'  num2str(mice_num{iexp}(isuj))];
            saveF(figH,figName,[dropbox '/DataSL/SleepScoring/Cumulative/'], ...
                'sformat',{'dpng'},'res',300,'savfig',0)  
        end
    end
end

