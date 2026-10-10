# Adapt-compatible JSON

Use only when the requested consumer expects Adapt's response shape. Return valid JSON with no prose or Markdown fences.

Fields:

- `confidenceScore`: integer 0–5, how safe the reviewed revision is to merge.
- `summary`: nonempty string; 1–2 sentences, at most 40 words, stating purpose and overall risk. Include a material verification limitation here if it affects the verdict.
- `files`: array of objects with `path` (repository-relative path) and `overview` (one phrase, at most 15 words).
- `findings`: array of objects with optional `file` and `line`, required `detail`, and `blocking`. Use one sentence of at most 30 words for `detail`, conveying the concrete issue and required fix. Set `blocking` explicitly even though the original backend schema permits omission.

Set `line` only with `file`, using a positive integer on the new/RIGHT side of the PR diff. Omit the location for a general finding, or keep only `file` for a file-level note. No side/range/title/priority fields belong to this contract.

An illustrative object (not a default verdict):

```json
{
  "confidenceScore": 2,
  "summary": "Adds queued delivery, but retries can send the same message twice after a timeout.",
  "files": [
    {
      "path": "src/delivery.ts",
      "overview": "Queues outbound messages and retries failed deliveries."
    }
  ],
  "findings": [
    {
      "file": "src/delivery.ts",
      "line": 42,
      "detail": "A timeout after delivery retries an already-sent message; persist an idempotency key before sending and reuse it on retries.",
      "blocking": true
    }
  ]
}
```

Use an empty `findings` array when there are no findings. Ensure a blocking finding never accompanies a score of 3 or above; lower a conflicting score to 2 or less and reconcile the summary. Do not give a passing verdict when the evidence is insufficient to evaluate the PR.

The original backend renders this into a review and separate inline comments. A local Codex skill does not automatically post that object anywhere.
