
% manually set variable amp with order from>back by building a matrix
% each row on the amplifier starting by front being a column 
% poistion order on connecteur

amp = [34	33	31	32
36	35	29	30
38	37	27	28
40	39	25	26
42	41	23	24
44	43	21	22
46	45	19	20
48	47	17	18
50	49	15	16
52	51	13	14
54	53	11	12
56	55	9	10
58	57	7	8
60	59	5	6
62	61	3	4
64	63	1	2];


shank = [54	58	4	8
59	36	26	5
45	37	27	19
46	38	24	16
47	50	12	17
55	61	3	9
56	60	2	6
42	34	28	20
43	35	29	21
44	48	14	18
52	51	13	10
57	62	0	7
39	63	1	25
40	33	31	22
41	30	15	23
53	32	49	11];

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

% this is the one you need 
shank_inv_intan = shank_inv-1;



% for i=1:size(amp,1)
%     for k=1:size(amp,2)
%         if ~isempty(find(shank(i,k)==amp))
%             pos(i,k) = find(shank(i,k)==amp);
%         else
%             pos(i,k) = nan;
%         end
%     end
% end
% 
% for i=1:size(amp,1)
%     for k=1:size(shank,2)
%         if ~isempty(find(shank(i,k)==amp_inv))
%             pos_inv2(i,k) = find(shank(i,k)==amp_inv);
%         else
%             pos_inv2(i,k) = nan;
%         end
%     end
% end
% 
% pos_inv = rot90(rot90(pos));
% %pos_inv_intan = pos_inv-1;
% posnan2 = pos;
% pos(isnan(pos))=1;
% shank_inv = amp_inv(pos);
% shank_inv_intant = shank_inv-1;
% 
% shank_inv2 = amp_inv(pos_inv2);
% shank_inv2_intan = shank_inv2-1;