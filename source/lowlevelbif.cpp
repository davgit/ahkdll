#define BETA // i.e. include allowances for binary number caching
#define BIF(fun) MCODE_API void fun(ExprTokenType &aResultToken, ExprTokenType *aParam[], int aParamCount)

BIF(__getvar)
{
	int i = 0;
	if (aParam[0]->symbol == SYM_VAR)
		i = (int)aParam[0]->var;
	aResultToken.value_int64 = i;
}

BIF(__static)
{
	if (aParam[0]->symbol == SYM_VAR)
	{
		Var *var = aParam[0]->var;
		if (var->mType == VAR_ALIAS)
			var = var->mAliasFor;
		var->mAttrib |= VAR_ATTRIB_STATIC;
	}
}

BIF(__alias)
{
	ExprTokenType &aParam0 = *aParam[0];
	ExprTokenType &aParam1 = *aParam[1];
	if (aParam0.symbol == SYM_VAR)
	{
		Var &var = *aParam0.var;

		UINT len = 0;
		switch (aParam1.symbol)
		{
		case SYM_VAR:
		case SYM_INTEGER:
			len = (UINT)aParam1.var;
		}
		var.mType = len ? VAR_ALIAS : VAR_NORMAL;
		var.mLength = len;
	}
}

BIF(__getTokenValue)
{
	ExprTokenType *token = aParam[0];
	
	if (token->symbol != SYM_INTEGER)
		return;
	
	token = (ExprTokenType*) token->value_int64;

    if (token->symbol == SYM_VAR)
    {
		Var &var = *token->var;

#ifdef BETA
		VarAttribType cache_attrib = var.mAttrib & (VAR_ATTRIB_HAS_VALID_INT64 | VAR_ATTRIB_HAS_VALID_DOUBLE);
		if (cache_attrib)
		{
			aResultToken.symbol = (SymbolType) (cache_attrib >> 4);
			aResultToken.value_int64 = var.mContentsInt64;
		}
		else
#endif
		{
			aResultToken.symbol = SYM_OPERAND;
			aResultToken.marker = var.mContents;
		}
    }
    else
    {
        aResultToken.symbol = token->symbol;
        aResultToken.value_int64 = token->value_int64;
    }
}

BIF(__cacheEnable)
{
	if (aParam[0]->symbol == SYM_VAR)
	{
		(aParam[0]->var->mType == VAR_ALIAS ? aParam[0]->var->mAliasFor : aParam[0]->var)
			->mAttrib &= ~VAR_ATTRIB_CACHE_DISABLED;
	}
}