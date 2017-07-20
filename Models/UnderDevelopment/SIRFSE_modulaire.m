classdef SIRFSE_modulaire
% ----------------------------------------------------------------------------------------------------
% SIRFSE :  qMT using Inversion Recovery Fast Spin Echo acquisition
% ----------------------------------------------------------------------------------------------------
% Assumptions :
% (1) FILL
% (2) 
% (3) 
% (4) 
% ----------------------------------------------------------------------------------------------------
%
%  Fitted Parameters:
%    * F      : pool size ratio
%    * kf     : rate of MT from the free to the restricted pool
%    * kr     : rate of MT from the restricted to the free pool
%    * R1f    : rate of longitudinal relaxation in the free pool when there is no MT (=1/T1f)
%    * R1r    : rate of longitudinal relaxation in the restricted pool when there is no MT (=1/T1r)
%    * Sf     : instantaneous fraction of magnetization after vs. before the pulse in the free pool
%    * Sr     : instantaneous fraction of magnetization after vs. before the pulse in the restricted pool
%    * M0f    : equilibrium value of the longitudinal magnetization for the free pool
%    * M0r    : equilibrium value of the longitudinal magnetization for the restricted pool
%    * resnorm: fitting residual 
%
%
%  Non-Fitted Parameters:
%    * 
%
%
% Options:
%   FILL
%
%
% ----------------------------------------------------------------------------------------------------
% Written by: Ian Gagnon, 2017
% Reference: FILL
% ----------------------------------------------------------------------------------------------------
    
    properties
        MRIinputs = {'MTdata','R1map','Mask'}; % input data required
        xnames = {'F','kr','R1f','R1r','Sf','Sr','M0f'}; % name of the fitted parameters
        voxelwise = 1; % voxel by voxel fitting?
        
        % fitting options
        st           = [ 0.1    30      1        1     -0.9     0.6564    1 ]; % starting point
        lb           = [ 0       0      0.05     0.05   -1       0         0 ]; % lower bound
        ub           = [ 1     100     10       10       0       1         2 ]; % upper bound
        fx           = [ 0       0      0        1       0       1         0 ]; % fix parameters
        
        % Protocol
        % You can define a default protocol here.
        Prot = struct('MTdata',...
                               struct('Format',{{'Ti' 'Td'}},...
                                      'Mat', [0.0030 3.5; 0.0037 3.5; 0.0047 3.5; 0.0058 3.5; 0.0072 3.5 
                                              0.0090 3.5; 0.0112 3.5; 0.0139 3.5; 0.0173 3.5; 0.0216 3.5
                                              0.0269 3.5; 0.0335 3.5; 0.0417 3.5; 0.0519 3.5; 0.0646 3.5 
                                              0.0805 3.5; 0.1002 3.5; 0.1248 3.5; 0.1554 3.5; 0.1935 3.5
                                              0.2409 3.5; 0.3000 3.5; 1.0000 3.5; 2.0000 3.5; 10.0000 3.5]),...
                      'FSEsequence',...
                               struct('Format',{{'Trf (s)'; 'Tr (s)'; 'Npulse'}},...
                                      'Mat',[0.001; 0.01; 16])); 
                                           
        % Model options
        buttons = {'PANEL','Inversion_Pulse',2,...
                   'Shape',{'hard','gaussian','gausshann','sinc','sinchann','sincgauss','fermi'},'Duration (s)', 0.001,...
                   'Use R1map to constrain R1f',false,...
                   'Fix R1r = R1f',true,...
                   'PANEL','Sr_Calculation',2,...
                   'T2r',1e-05,...       
                   'Lineshape',{'SuperLorentzian','Lorentzian','Gaussian'}};
        options= struct(); % structure filled by the buttons. Leave empty in the code
        
        % Simulations Default options
        Sim_Single_Voxel_Curve_buttons = {'Method',{'Analytical equation','Block equation'},'Reset Mz',false};
        Sim_Sensitivity_Analysis_buttons = {'# of run',5};
    end
    
    methods
        function obj = SIRFSE_modulaire
            obj.options = button2opts(obj.buttons);
            obj = UpdateFields(obj);
        end
        
        function obj = UpdateFields(obj)
            if obj.options.UseR1maptoconstrainR1f
                obj.fx(3) = true;
            end
            SrParam = GetSrParam(obj);
            SrProt = GetSrProt(obj);
            obj.st(6) = computeSr(SrParam,SrProt);
        end
        
        function mz = equation(obj, x, Opt)
            for ix = 1:length(x)
                Sim.Param.(obj.xnames{ix}) = x(ix);
            end
            Protocol = GetProt(obj);
            switch Opt.Method
                case 'Block equation'
                    Sim.Param.lineshape = obj.options.Lineshape;
                    Sim.Param.M0f = 1;
                    Sim.Opt.Reset = Opt.ResetMz;
                    Sim.Opt.SScheck = 1;
                    Sim.Opt.SStol = 1e-4;
                    mz = SIRFSE_sim(Sim, Protocol, 1);
                case 'Analytical equation'
                    Sim.Param.Sf = -Sim.Param.Sf;
                    SimCurveResults = SIRFSE_SimCurve(Sim.Param, Protocol, obj.GetFitOpt,0);
                    mz = SimCurveResults.curve;
            end
        end
        
        function FitResults = fit(obj,data)            
            Protocol = GetProt(obj);       
            FitOpt = GetFitOpt(obj,data);
            FitResults = SIRFSE_fit(data.MTdata,Protocol,FitOpt);
            FitResults.Sf = - FitResults.Sf;
        end
        
        function plotmodel(obj, x, data)
            Protocol = GetProt(obj);
            FitOpt = GetFitOpt(obj,data);
            x.Sf = - x.Sf;
            SimCurveResults = SIRFSE_SimCurve(x, Protocol, FitOpt );
            Sim.Opt.AddNoise = 0;
            SIRFSE_PlotSimCurve(data.MTdata, data.MTdata, Protocol, Sim, SimCurveResults);
            title(sprintf('F=%0.2f; kf=%0.2f; R1f=%0.2f; R1r=%0.2f; Sf=%0.2f; Sr=%f; M0f=%0.2f; Residuals=%f',...
                x.F,x.kf,x.R1f,x.R1r,-x.Sf,x.Sr,x.M0f,x.resnorm), ...
                'FontSize',10);
        end
        
        function FitResults = Sim_Single_Voxel_Curve(obj, x, Opt,display)
            % Example: obj.Sim_Single_Voxel_Curve(obj.st,button2opts(obj.Sim_Single_Voxel_Curve_buttons))
            if ~exist('display','var'), display = 1; end
            Smodel = equation(obj, x+eps, Opt);
            sigma = max(Smodel)/Opt.SNR;
            data.MTdata = random('rician',Smodel,sigma);
            FitResults = fit(obj,data);
            if display
                plotmodel(obj, FitResults, data);
            end
        end
        
        function SimVaryResults = Sim_Sensitivity_Analysis(obj, OptTable, Opts)
            % SimVaryGUI
            SimVaryResults = SimVary(obj, Opts.Nofrun, OptTable, Opts);
        end
        
        function SimRndResults = Sim_Multi_Voxel_Distribution(obj, RndParam, Opt)
            % SimRndGUI
            SimRndResults = SimRnd(obj, RndParam, Opt);
        end

%         function plotProt(obj)
%             subplot(1,1,2)
%             plot(obj.Prot.MTdata(:,1),obj.Prot.MTdata(:,2))
%             subplot(2,1,2)
%             title('MTpulse')
%             angles = Prot.Angles(1);
%             offsets = Prot.Offsets(1);
%             shape = Prot.MTpulse.shape;
%             Trf = Prot.Tm;
%             PulseOpt = Prot.MTpulse.opt;
%             Pulse = GetPulse(angles, offsets, Trf, shape, PulseOpt);
%             figure();
%             ViewPulse(Pulse,'b1');
%         end
%         
        function Prot = GetProt(obj)  
            Prot.ti = obj.Prot.MTdata.Mat(:,1);
            Prot.td = obj.Prot.MTdata.Mat(:,2);
            Prot.Trf = obj.Prot.FSEsequence.Mat(1);
            Prot.Tr = obj.Prot.FSEsequence.Mat(2);
            Prot.Npulse = obj.Prot.FSEsequence.Mat(3);  
        end
        
        function FitOpt = GetFitOpt(obj,data)
            if exist('data','var')
                if isfield(data,'R1map'), FitOpt.R1 = data.R1map; end
            end
            FitOpt.R1map = obj.options.UseR1maptoconstrainR1f;
            FitOpt.names = obj.xnames;
            FitOpt.fx = obj.fx;
            FitOpt.st = obj.st;
            FitOpt.lb = obj.lb;
            FitOpt.ub = obj.ub;
            FitOpt.R1reqR1f = obj.options.FixR1rR1f;
        end
        
        function SrParam = GetSrParam(obj)           
            SrParam.F = 0.1;
            SrParam.kf = 3;
            SrParam.kr = SrParam.kf/SrParam.F;
            SrParam.R1f = 1;
            SrParam.R1r = 1;
            SrParam.T2f = 0.04;
            SrParam.T2r = obj.options.Sr_Calculation_T2r; 
            SrParam.M0f = 1;
            SrParam.M0r = SrParam.F*SrParam.M0f;
            SrParam.lineshape = obj.options.Sr_Calculation_Lineshape;
        end
        
        function SrProt = GetSrProt(obj)
            SrProt.InvPulse.Trf = obj.Prot.FSEsequence.Mat(1);
            SrProt.InvPulse.shape = obj.options.Inversion_Pulse_Shape;
        end
    end
end