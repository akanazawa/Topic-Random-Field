% getNeighors.m
% assuming data is a struct with field adj, a Nd by Nd matrix of
% neighbors, get the top E closest neighbors of region n
% INPUT - data: struct with adj
%       - n: region index
%       - E: number of neighbors to get
% OUTPUT - ngbh: index of neighbors
%
% Angjoo Kanazawa 12/13/2011

function [ngbh] = getNeighbors(data, n, E)
    ngbh = find(data.adj(n,:));
    if numel(ngbh) > E
        % for the moment permute, but later write code to get
        % closest ones
        ngbh = ngbh(randperm(numel(ngbh))); 
        ngbh = ngbh(1:E); % pick first E nbghs
    end
end
