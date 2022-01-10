
% manually set variable amp with order from>back by building a matrix
% each row on the amplifier starting by front being a column 
% poistion order on connecteur
amp = ...
[301 302 303 304
49 33 17 1
50 34 18 2
51 35 19 3
52 36 20 4 
53 37 21 5
54 38 22 6 
55 39 23 7 
56 40 24 8
57 41 25 9
58 42 26 10
59 43 27 11
60 44 28 12
61 45 29 13
62 46 30 14
63 47 31 15];
% [34	33	31	32
% 36	35	29	30
% 38	37	27	28
% 40	39	25	26
% 42	41	23	24
% 44	43	21	22
% 46	45	19	20
% 48	47	17	18
% 50	49	15	16
% 52	51	13	14
% 54	53	11	12
% 56	55	9	10
% 58	57	7	8
% 60	59	5	6
% 62	61	3	4
% 64	63	1	2];

% position order on each shank
shank = ...
[0 9 53 63
1 11 49 62 
8 17 45 44
22 28 34 39
20 6 58 41
2 12 52 61
3 21 36 54
16 18 43 51
25 30 33 37
24 7 57 38
4 15 50 60 
10 13 47 55
19 23 40 42
14 29 32 46
26 31 48 35
5 27 56 59];

% [54	58	4	8
% 59	36	26	5
% 45	37	27	19
% 46	38	24	16
% 47	50	12	17
% 55	61	3	9
% 56	60	2	6
% 42	34	28	20
% 43	35	29	21
% 44	48	14	18
% 52	51	13	10
% 57	62	0	7
% 39	63	1	25
% 40	33	31	22
% 41	30	15	23
% 53	32	49	11];

shank = shank +1;

% get shank position on connector
for i=1:size(shank,1)
    for k=1:size(shank,2)
        if ~isempty(find(amp==shank(i,k)))
            pos(i,k) = find(amp==shank(i,k));
        else
            pos(i,k) = nan;
        end
        
    end
end
% reverse the amp 
amp_inv = rot90(rot90(amp));
posnan = pos;
pos(isnan(pos))=1;
shank_inv = amp_inv(pos);
shank_inv_intan = shank_inv-1;



for i=1:size(amp,1)
    for k=1:size(amp,2)
        if ~isempty(find(shank(i,k)==amp))
            pos(i,k) = find(shank(i,k)==amp);
        else
            pos(i,k) = nan;
        end
    end
end

for i=1:size(amp,1)
    for k=1:size(shank,2)
        if ~isempty(find(shank(i,k)==amp_inv))
            pos_inv2(i,k) = find(shank(i,k)==amp_inv);
        else
            pos_inv2(i,k) = nan;
        end
    end
end

pos_inv = rot90(rot90(pos));
%pos_inv_intan = pos_inv-1;
posnan2 = pos;
pos(isnan(pos))=1;
shank_inv = amp_inv(pos);
shank_inv_intant = shank_inv-1;

shank_inv2 = amp_inv(pos_inv2);
shank_inv2_intan = shank_inv2-1;