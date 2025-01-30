classdef SimpleAllPassPlugin < audioPlugin
    properties
        Fc = 1000;  % Default cutoff frequency (Hz)
    end

    properties (Constant)
        Fs = 48000;  % Sampling frequency (Hz)
        PluginInterface = audioPluginInterface( ...
            audioPluginParameter('Fc', ...
            'DisplayName', 'Cutoff Frequency', ...
            'Mapping', {'log', 20, 20000})) % 20 Hz ~ 20 kHz (log scale)
    end

    properties (Access = private)
        allpassFilter; % Handle object for dsp.AllpassFilter
    end

    methods
        function plugin = SimpleAllPassPlugin()
            % Initialize filter object
            plugin.allpassFilter = dsp.AllpassFilter();
            % Initial filter configuration
            plugin.updateFilter();
        end

        function set.Fc(plugin, Fc)
            % Update filter coefficients when Fc is changed
            plugin.Fc = Fc;
            plugin.updateFilter();
        end

        function out = process(plugin, in)
            % Apply all-pass filter
            out = plugin.allpassFilter(in);
        end

        function alpha = getFilterCoefficients(plugin)
            % Provide filter coefficients externally
            alpha = plugin.allpassFilter.AllpassCoefficients;
        end
    end

    methods (Access = private)
        function updateFilter(plugin)
            % Convert cutoff frequency Fc -> filter coefficient alpha
            alpha = (tan(pi * plugin.Fc / plugin.Fs) - 1) / ...
                    (tan(pi * plugin.Fc / plugin.Fs) + 1);
        
            % Must be passed as an N×1 matrix
            plugin.allpassFilter.AllpassCoefficients = alpha(:);
        end
    end
end
