.. _man-models:

******
Models
******

This section describes the optimization models that are planned to be shipped with the platform. The models to be implemented are defined in their mathematical notation.
	
|	:math:`\mathbf{1}` & vector of all ones
|	:math:`n` & number of assets in the ``Asset_Group``
|	:math:`k` & number of scenarios
|	:math:`\Sigma\in\mathbb{R}^{n\times n}` & covariance matrix of the ``Asset_Group``
|	:math:`\mu\in\mathbb{R}^n` & vector of expected returns of the ``Asset_Group``
|	:math:`r\in\mathbb{R}` & target return
|	:math:`w\in\mathbb{R}^n` & weights vector to be found
|	:math:`\Theta\in\mathbb{R}^{n\times n}` & ellipsoidal uncertainty set of true expected returns
|	:math:`\epsilon\in\mathbb{R}` & square of a size of uncertainty set
|	:math:`L\in\mathbb{R}^{n\times k}` & matrix of assets' losses where each row corresponds to the Monte-Carlo scenario
|	:math:`\alpha\in (0,\, 0.5)` & area of the right tale of the losses distribution at which CVaR is computed
|	:math:`\mathcal{F}\subseteq \mathbb{R}^n` & feasible space defined by inputs ``constraints`` and ``short_sale``
|	:math:`y\in\mathbb{R}^k,\; q\in\mathbb{R}` & auxiliary decision variables
	

Simple Mean Variance Optimization
----------------------------------

:func:`Simple MVO <SimpleMVO>`

The simple mean variance optmization is a technique to optimally allocate investments between assets. The gaol is globally reduce risk on investment at a specified expected return based on the covariance between asset groups. In a Simple MVO, the expect inputs are, **expected return of assets** and **correlation matrix between assets**. Given this, the optimization algorith will be able to output an optimal portfolio weight. 

In previous manuals you will have already learned about creating assets groups as well as constraint group. These groups can now be used to create a Simple MVO with the follow code.


.. code-block:: julia

	mvo = SimpleMVO(Asset_Group, target_return, constraints, short_sale)
	optimize(mvo, parameters)

==============  ==================================================================
Variable Name   Description                                                      
==============  ==================================================================
Asset Group     Set of Asset returns and covarianced inputtedf or analysis         
Target_Return   Expected target return of portfolio post optimization                
Constraints     Any non-model specific constraints to be used in optimization         
Short_Sale      A boolean indicating whether or not short selling will be allowed 
==============  ==================================================================

Robust Mean Variance Optimization
----------------------------------

:func:`Robust MVO <RobustMVO>`

Other methods of optimization such as Robust Mean Variance Optimization can also be applied onto asset and constraint groups.

.. code-block:: julia

	rmvo = RobustMVO(Asset_Group, target_return, constraints, uncertainty_set, uncertainty_set_size, short_sale)
	optimize(rmvo, parameters) 

====================  ==================================================================
Variable Name         Description                                                      
====================  ==================================================================
Asset Group           Set of Asset returns and covarianced inputtedf or analysis         
Target_Return         Expected target return of portfolio post optimization                
Constraints           Any non-model specific constraints to be used in optimization      
Uncertainty_Set                                                                         
Uncertainty_Set_Size                                                                   
Short_Sale            A boolean indicating whether or not short selling will be allowed 
====================  ==================================================================

.. comment

	TODO: Uncertainty_Set stuff

Minimum-Variance Optimization
----------------------------------

:func:`Minimum Variance Optimization <MinVarO>`

In minimum-variance optmization, the goal is to minize the risk of the portfolio. 

.. code-block:: julia

	mvar = MinVarO(Asset_Group, constraints, short_sale)
	optimize(mvar, parameters) 

==============  ================================================================== 
Variable Name   Description                                                      
==============  ==================================================================
Asset Group     Set of Asset returns and covarianced inputtedf or analysis        
Constraints     Any non-model specific constraints to be used in optimization         
Short_Sale      A boolean indicating whether or not short selling will be allowed 
==============  ==================================================================

Conditional Value at Risk (CVaR) Optimization
----------------------------------------------

:func:`CVaR Optimization <CVaRO>`

.. code-block:: julia

	cvar = CVaRO(Asset_Group, losses, constraints, alpha, short_sale)
	optimize(cvar, parameters) 

==============  ================================================================== 
Variable Name   Description                                                     
==============  ==================================================================
Asset Group     Set of Asset returns and covarianced inputtedf or analysis         
Losses                                                                            
Constraints     Any non-model specific constraints to be used in optimization       
Alpha                                                                              
Short_Sale      A boolean indicating whether or not short selling will be allowed 
==============  ==================================================================


Function Descriptions
---------------------

============================================================================  ============================================================================
Function                                                                      Description
============================================================================  ============================================================================
:func:`optimize(M, parameters; solver=Default) <optimize>`					  Will optimize the model ``M`` with the ``parameters`` given using a ``solver`` 
:func:`getDefaultConstraints(M) <getDefaultConstraints>`					  Return the default constraints of model ``M`` .
:func:`getConstraints(M) <getConstraints>`									  Return the constraints as an array of expressions for model ``M`` .
:func:`getObjective(M) <getObjective>`										  Return the objective function of model ``M`` as an Expr type.
:func:`getSense(M) <getSense>`												  Return the Sense of the model ``M`` , Min or Max.
:func:`getVariables(M) <getVariables>`										  Return the list of variables in the model ``M`` .
============================================================================  ============================================================================

To change solvers, refer to the :ref:`solver select <solver-sel>` tutorial.

