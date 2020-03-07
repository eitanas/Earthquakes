function [st_idxs] = buildStartIndicesWindowsTimeWithOverlap(window_len, ovrlp, start_t, max_t)
%UNTITLED3 Summary of this function goes here
%   max_t is in seconds

st_idxs = start_t;

end_t = max_t - window_len;
jump = window_len - ovrlp;
pointer = start_t + jump;

while (pointer < end_t)
    st_idxs = [st_idxs pointer];
    pointer = pointer + jump;
end

st_idxs = st_idxs(1:end);

end