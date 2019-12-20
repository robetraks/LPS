function rounded = my_round(in, varargin)
% returns a rounded number with roundtoDigits decimal places supplied as varagin. 
% Basically used to reduce the precision when the input double contains
% more decimal places than desired.
    if(nargin == 1)
        roundtoDigits = 2;
    else
        roundtoDigits = varargin{1};
    end
    rounded = (round(in*(10^roundtoDigits)))/(10^roundtoDigits);
end
    