%CMPUT 650: Probabilistic Graphical Models
%Course Project: Resource Limited Monitoring
%Cody Rosevear, Hayden Barker
%Department Of Computing Science
%University Of Alberta
%Edmonton, AB, T6G 2E8, Canada
%rosevear@ualberta.ca, hsbarker@ualberta.ca
addpath(genpathKPM(pwd))

disp('Constructing the influence diagram');

%we number nodes down and to the right
S_true = [1 6];
S_obs = [2 7] ;
test_d = [3 8] ;
treat_d = [4 9];
utility = [5 10];

N = 10;

dag = zeros(N);

%T = 1
%Intraslice edges
%S1* -> U1 
dag(1, 5) = 1;
%Sob1 -> Test1
dag(2, 3) = 1;
%Sob1 -> Treat1
dag(2, 4) = 1;
%Test1 -> Treat1
dag(3, 4) = 1;
%Test1 -> U1
dag(3, 5) = 1;
%Treat1 -> U1
dag(4, 5) = 1;

%T = 1
%Interslice edges
%S1* -> S2*
dag(1, 6) = 1;

%T = 2

%Set node sizes (number of values for each node)
ns = 2 * ones(1, N);
ns(utility) = 1;
ns
 
%Indices in the limid CPD attribute that pick out the various cpds
S_true_params = 2:3;
S_obs_params = 4;
test_d_params = 5:6;
treat_d_params = 7:8;
util_params = 9:10;

%Params(i) = j signifies that node i has a cpd defined at limid.CPD(i)
params = ones(1, N);
params(S_true) = S_true_params;
params(S_obs) = S_obs_params;
params(test_d) = test_d_params;
params(treat_d) = treat_d_params;
params(utility) = util_params;

%Make the influence diagram
limid = mk_limid(dag, ns, 'chance', [S_obs S_true], 'decision', [test_d treat_d], 'utility', utility, 'equiv_class', params);

%Symptom CPDs
%limid.CPD{S_true_params} = tabular_CPD(limid, S_true(1));
limid.CPD{S_obs_params} = tabular_CPD(limid, S_obs(1));

%Decision And Utility CPD
for i = 1:2
    limid.CPD{S_true_params(i)} = tabular_CPD(limid, S_true(i));
    
    %Decision
    limid.CPD{test_d_params(i)} = tabular_decision_node(limid, test_d(i));
    limid.CPD{treat_d_params(i)} = tabular_decision_node(limid, treat_d(i));
    %Utility
    limid.CPD{util_params(i)} = tabular_utility_node(limid, utility(i));
end


inf_engine = jtree_limid_inf_engine(limid);
max_iter = 1;

disp('Solving the current influence diagram');
[strategy, MEU, niter] = solve_limid(inf_engine, 'max_iter', max_iter);
MEU

% % check results match those in the paper (p. 22)
% direct_policy = eye(2); % treat iff test is positive
% never_policy = [1 0; 1 0]; % never treat
% tol = 1e-0; % results in paper are reported to 0dp
% for e=exact(:)'
%   switch fig
%    case 2, % reactive policy
%     assert(approxeq(MEU(e), 727, tol));
%     assert(approxeq(strategy{e}{d(1)}(:), never_policy(:)))
%     assert(approxeq(strategy{e}{d(2)}(:), direct_policy(:)))
%     assert(approxeq(strategy{e}{d(3)}(:), direct_policy(:)))
%    case 1, assert(approxeq(MEU(e), 729, tol));
%    case 7, assert(approxeq(MEU(e), 732, tol));
%   end
% end


% for e=approx(:)'
%   for i=1:3
%     approxeq(strategy{exact(1)}{d(i)}, strategy{e}{d(i)})
%     dispcpt(strategy{e}{d(i)})
%   end
% end


