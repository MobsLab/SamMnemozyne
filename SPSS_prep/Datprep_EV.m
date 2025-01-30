load('EV_MFB.mat');
n = size(EV{1,1}{1},2);

clear ev_nrem ev_rem rev_nrem rev_rem
for i=1:5
    ev_nrem(1:n,i) = EV{1,1}{i}';
    ev_rem(1:n,i) = EV{2,1}{i}';
    rev_nrem(1:n,i) = REV{1,1}{i}';
    rev_rem(1:n,i) = REV{2,1}{i}';
end

