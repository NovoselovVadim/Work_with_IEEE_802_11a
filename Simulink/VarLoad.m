function VarLoad
    cfg = load('D:\NIR\WIFI\AGC\Simulink_model\Signals\STF_802_11a.mat');
    assignin('base','STF',cfg.coef)

    cfg = load('D:\NIR\WIFI\AGC\Simulink_model\Signals\FreqOffset.mat');
    assignin('base','F',cfg.Fk)
end