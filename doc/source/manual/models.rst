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
	

Minimum-Variance Optimization
----------------------------------

:func:`Minimum Variance Optimization <MinVarO>`

|	:math:`\min` :math:`w^\top\Sigma w`
|	subject to :math:`\mathbf{1}^\top w = 1`
|	:math:`w\in\mathcal{F}`

MinVarO(Asset_Group(:math:`\Sigma, \mu`), constraints, short_sale)

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


Simple Mean Variance Optimization
----------------------------------

:func:`Simple MVO <SimpleMVO>`

|	 :math:`\min` :math:`w^\top\Sigma w`
|	 subject to :math:`\mu^\top w \geq r`
|	 :math:`\mathbf{1}^\top w = 1`
|	 :math:`w\in\mathcal{F}`

SimpleMVO(Asset_Group(:math:`\Sigma, \mu`), :math:`r`, constraints, short_sale)}

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

|	:math:`\min` :math:`w^\top\Sigma w`
|	subject to :math:`\lVert{\Theta^{\frac{1}{2}}w}\rVert \leq \sqrt{\epsilon}` or equivalently :math:`w^\top\Theta w \leq\epsilon`
|	:math:`\mu^\top w \geq r`
|	:math:`\mathbf{1}^\top w = 1`
|	:math:`w\in\mathcal{F}`

RobustMVO(Asset_Group(:math:`\Sigma, \mu`), :math:`r`, constraints, :math:`\Theta`, :math:`\epsilon`, short_sale)

.. code-block:: julia

	rmvo = RobustMVO(Asset_Group, target_return, constraints, uncertainty_set, uncertainty_set_size, short_sale)
	optimize(rmvo, parameters) 

====================  ==================================================================
Variable Name         Description                                                      
====================  ==================================================================
Asset Group           Set of Asset returns and covarianced inputtedf or analysis         
Target_Return         Expected target return of portfolio post optimization                
Constraints           Any non-model specific constraints to be used in optimization      
Uncertainty_Set       Uncertainties in the parameter estimates (:math:`\Sigma` and :math:`\mu`) associated with each asset in the asset group. Typically taken to be an individual variance of each asset                                                                  
Uncertainty_Set_Size  maximum allowable exposure of the whole portfolio to the uncertainty associated with the parameter estimates (:math:`\Sigma` and :math:`\mu`)                                                                 
Short_Sale            A boolean indicating whether or not short selling will be allowed 
====================  ==================================================================

Conditional Value at Risk (CVaR) Optimization
----------------------------------------------

:func:`CVaR Optimization <CVaRO>`

|	:math:`\min` :math:`q + \frac{\mathbf{1}^\top y}{N(1 - \alpha)}`
|	subject to :math:`L^\top w - q \mathbf{1} - y \preceq 0`
|	:math:`y \succeq 0`
|	:math:`w\in\mathcal{F}`

CVaRO(Asset_Group(:math:`\Sigma, \mu`), :math:`L`, constraints, :math:`\alpha`, short_sale)

.. code-block:: julia

	cvar = CVaRO(Asset_Group, losses, constraints, alpha, short_sale)
	optimize(cvar, parameters) 

==============  ================================================================== 
Variable Name   Description                                                     
==============  ==================================================================
Asset Group     Set of Asset returns and covarianced inputtedf or analysis         
Losses          Matrix of samples of the portfolio losses, where each row represents a sample. Typically obtained by Monte-Carlo sampling                                                                  
Constraints     Any non-model specific constraints to be used in optimization       
Alpha           Confidence level at which CVaR is optimized. This corresponds to the area of the left tale of the losses distribution                                                                   
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

