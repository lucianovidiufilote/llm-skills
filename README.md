# llm-skills

## If using Codex
Symlink into your project:
ln -s /absolute_path_to_llm-skills/.codex /absolute_path_to_target_project/.codex
ln -s /absolute_path_to_llm-skills/AGENTS.md /absolute_path_to_target_project/AGENTS.md

mkdir -p /absolute_path_to_target_project/.agents && \
ln -sfn /absolute_path_to_llm-skills/skills /absolute_path_to_target_project/.agents/skills