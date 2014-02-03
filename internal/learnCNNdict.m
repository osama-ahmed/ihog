function pd = learnCNNdict(chunkmasterfile, k, lambda, iters, fast),

if ~exist('k', 'var'),
  k = 1024;
end
if ~exist('lambda', 'var'),
  lambda = 0.02; % 0.02 is best so far
end
if ~exist('iters', 'var'),
  iters = 10;
end
if ~exist('fast', 'var'),
  fast = false;
end

t = tic;

fprintf('icnn: locating chunkfiles...\n');
master = load(chunkmasterfile);
master = master.master;

for i=1:length(master.files),
  fprintf('icnn: valid chunk: %s\n', master.files{i})
end

param.K = k;
param.lambda = lambda;
param.mode = 2;
param.modeD = 0;
param.iter = 100;
param.numThreads = 12;
param.verbose = 1;
param.batchsize = 400;
param.posAlpha = true;

model = struct();
for i=1:iters,
  chunkid = floor(length(master.files)*rand()+1);
  data = load(sprintf('%s/%s', fileparts(chunkmasterfile), master.files{chunkid}));

  fprintf('icnn: iteration #%i: chunk=%s, n=%i\n', i, master.files{chunkid}, size(data.data,2));

  [dict, model] = mexTrainDL(data.data, param, model);
  model.iter = i*param.iter;
  param.D = dict;
end

pd.drgb = dict(1:prod(master.imdim), :);
pd.dcnn = dict(prod(master.imdim)+1:end, :);
pd.n = master.n;
pd.k = k;
pd.imdim = master.imdim;
pd.featdim = master.featdim;
pd.chunkmaster = master;
pd.lambda = lambda;
pd.feat = 'CNN';

fprintf('icnn: paired dictionaries learned in %0.3fs\n', toc(t));
