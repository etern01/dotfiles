# Alias tips - shows hint when you type a command that has an alias
_alias_tips_preexec() {
    local cmd=$1
    local alias_name
    for alias_name in $(alias | cut -d= -f1 | sed "s/alias '//"); do
        if [[ "$cmd" == "$alias_name"* ]] && [[ "$cmd" != "$alias_name " ]]; then
            local alias_value=$(alias "$alias_name" 2>/dev/null | cut -d= -f2- | sed "s/^'//;s/'$//")
            if [ -n "$alias_value" ]; then
                echo -e "\e[90mTip: $alias_name → $alias_value\e[0m"
            fi
        fi
    done
}

# Only enable if not already set
if [[ -z "$PROMPT_COMMAND" || "$PROMPT_COMMAND" != *"alias_tips"* ]]; then
    PROMPT_COMMAND="_alias_tips_preexec \"\${BASH_COMMAND:-}\"; ${PROMPT_COMMAND:-}"
fi
