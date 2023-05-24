BEGIN
	SET NOCOUNT ON
	DECLARE @True [bit] = 1
	DECLARE @False [bit] = 0
	IF NOT EXISTS
	(
		SELECT 1
			FROM [ActiveDirectory].[UserAccountControl]
			WHERE [UserAccountControl].[UserAccountControlId] = @UserAccountControl
	)
		BEGIN
			INSERT INTO [ActiveDirectory].[UserAccountControl]
			(
				[UserAccountControlId],
				[LoginScriptWillRun],
				[AccountIsDisabled],
				[HomeDirectoryIsRequire],
				[AccountIsLockedOut],
				[PasswordIsNotRequired],
				[UserCannotChangePassword],
				[UserCanSendEncryptedPassword],
				[AccountFor MatchingAccountInTrustedDomain],
				[NormalAccount],
				[InternalDomainTrustAccount],
				[WorkstationTrustAccount],
				[ServerTrustAccount],
				[PasswordNeverExpires],
				[MajorityNodeSetLogonAccount],
				[SmartcardIsRequired],
				[AccountIsTrustedForDelegation],
				[AccountIsNotDelegated],
				[OnlyAllowDataEncryptionStandardKeyTypes],
				[DoNotRequireKerberosPerAuthorization],
				[PasswordHasExpired],
				[AccountIsTrustedForAuthenticationDelegation],
				[AccountIsReadOnlyDomainController]
			)
				SELECT
					@UserAccountControl AS [UserAccountControlId],
					IIF((@UserAccountControl & 1) <> 0, @True, @False) AS [LoginScriptWillRun],
					IIF((@UserAccountControl & 2) <> 0, @True, @False) AS [AccountIsDisabled],
					IIF((@UserAccountControl & 8) <> 0, @True, @False) AS [HomeDirectoryIsRequire],
					IIF((@UserAccountControl & 16) <> 0, @True, @False) AS [AccountIsLockedOut],
					IIF((@UserAccountControl & 32) <> 0, @True, @False) AS [PasswordIsNotRequired],
					IIF((@UserAccountControl & 64) <> 0, @True, @False) AS [UserCannotChangePassword],
					IIF((@UserAccountControl & 128) <> 0, @True, @False) AS [UserCanSendEncryptedPassword],
					IIF((@UserAccountControl & 256) <> 0, @True, @False) AS [AccountFor MatchingAccountInTrustedDomain],
					IIF((@UserAccountControl & 512) <> 0, @True, @False) AS [NormalAccount],
					IIF((@UserAccountControl & 2048) <> 0, @True, @False) AS [InternalDomainTrustAccount],
					IIF((@UserAccountControl & 4096) <> 0, @True, @False) AS [WorkstationTrustAccount],
					IIF((@UserAccountControl & 8192) <> 0, @True, @False) AS [ServerTrustAccount],
					IIF((@UserAccountControl & 65536) <> 0, @True, @False) AS [PasswordNeverExpires],
					IIF((@UserAccountControl & 131072) <> 0, @True, @False) AS [MajorityNodeSetLogonAccount],
					IIF((@UserAccountControl & 262144) <> 0, @True, @False) AS [SmartcardIsRequired],
					IIF((@UserAccountControl & 524288) <> 0, @True, @False) AS [AccountIsTrustedForDelegation],
					IIF((@UserAccountControl & 1048576) <> 0, @True, @False) AS [AccountIsNotDelegated],
					IIF((@UserAccountControl & 2097152) <> 0, @True, @False) AS [OnlyAllowDataEncryptionStandardKeyTypes],
					IIF((@UserAccountControl & 4194304) <> 0, @True, @False) AS [DoNotRequireKerberosPerAuthorization],
					IIF((@UserAccountControl & 8388608) <> 0, @True, @False) AS [PasswordHasExpired],
					IIF((@UserAccountControl & 16777216) <> 0, @True, @False) AS [AccountIsTrustedForAuthenticationDelegation],
					IIF((@UserAccountControl & 67108864) <> 0, @True, @False) AS [AccountIsReadOnlyDomainController]
		END
END
