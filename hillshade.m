function [HS, light_dir, flat_reflection] = hillshade(Z, varargin)
    % HILLSHADE calculate hillshade of a DEM
    % Syntax
    %   HS = hillshade(Z)
    %   HS = hillshade(Z, "Dx", Dx, ...
    %       "azimuth", az_deg, "altitude", al_deg, ...
    %       "z_factor", ex_fac)
    %   HS = hillshade(Z, "Dx", Dx, ...
    %       "light_direction", light_dir, ...
    %       "z_factor", ex_fac)
    % Input
    %   Z: DEM matrix in metres. The matrix index should be in the (j,i) format, as of mdgrid
    % Parameters
    %   "Dx": Grid spacing in metres (default = 1)
    %   "azimuth": Azimuth angle in degrees (default = 45)
    %   "altitude": Altitude angle in degrees (default = 45)
    %   "light_direction": Light direction vector (default = [0,0,0])
    %   "z_factor": Vertical exaggeration factor (default = 1)
    % Either "azimuth" and "altitude" or "light_direction" should be specified.
    % Output
    %   HS: Hillshade matrix, with the same size as Z
    %   light_dir: Light direction vector used in the calculation
    %   flat_reflection: Hillshade value of a flat surface

    % Assigning default parameters
    Dx = 1;
    az = 45;
    al = 45;
    light_dir = [0, 0, 0];
    ex_fac = 1;

    % Input parameters
    p = inputParser;
    addRequired(p, "Z"); % DEM matrix
    addOptional(p, "Dx", Dx);
    addOptional(p, "azimuth", az);
    addOptional(p, "altitude", al);
    addOptional(p, "light_direction", light_dir);
    addOptional(p, "z_factor", ex_fac);
    parse(p, Z, varargin{:});
    Z = p.Results.Z;
    Dx = p.Results.Dx;
    az = p.Results.azimuth;
    al = p.Results.altitude;
    light_dir = p.Results.light_direction;
    ex_fac = p.Results.z_factor;

    % Parameters cleaning
    Z_ex = Z * ex_fac / Dx;

    if norm(light_dir(:)) == 0
        light_dir = light_dir_calc(az, al);
    else
        light_dir = light_dir / sum(light_dir .^ 2);
    end

    light_dir = light_dir * sign(light_dir(3));
    light_dir = reshape(light_dir, [1, 1, 3]);
    flat_reflection = light_dir(3);

    % Calculate hillshade
    N = zeros([size(Z_ex), 3]);
    [N(:, :, 1), N(:, :, 2), N(:, :, 3)] = surfnorm(Z_ex);
    Light_dir = repmat(light_dir, [size(Z_ex)]);
    HS = sum(Light_dir .* N, 3);
    HS = max(HS, 0);
end

function light_dir = light_dir_calc(az, al)
    light_dir = [sind(az) * cosd(al), cosd(az) * cosd(al), sind(al)];
end
