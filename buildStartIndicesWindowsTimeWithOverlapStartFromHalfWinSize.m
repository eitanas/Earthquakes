function [st_idxs] = buildStartIndicesWindowsTimeWithOverlapStartFromHalfWinSize(window_len, ovrlp, start_t, max_t)
%UNTITLED3 Summary of this function goes here
%   max_t is in seconds

st_idxs = window_len/2;

end_t = max_t-window_len/2;
jump =  ovrlp;
pointer = window_len/2 + jump;

while (pointer < end_t)
    st_idxs = [st_idxs pointer];
    pointer = pointer + jump;
end

st_idxs = st_idxs(1:end);

end