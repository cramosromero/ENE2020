clc;clear;close all;
load carsmall
X = [Weight,Horsepower,Acceleration];
mdl = fitlm(X,MPG)